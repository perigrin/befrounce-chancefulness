use 5.40.0;
use experimental 'class';

use DBI;

my sub uuid() {
    my $uuid = join '', map { pack( 'I', int( rand( 2**32 ) ) ) } ( 1 .. 4 );

    # current timestamp in ms
    my $timestamp = int( Time::HiRes::time() * 1000 );

    # timestamp
    substr( $uuid, 0, 1, chr( ( $timestamp >> 40 ) & 0xFF ) );
    substr( $uuid, 1, 1, chr( ( $timestamp >> 32 ) & 0xFF ) );
    substr( $uuid, 2, 1, chr( ( $timestamp >> 24 ) & 0xFF ) );
    substr( $uuid, 3, 1, chr( ( $timestamp >> 16 ) & 0xFF ) );
    substr( $uuid, 4, 1, chr( ( $timestamp >> 8 ) & 0xFF ) );
    substr( $uuid, 5, 1, chr( $timestamp & 0xFF ) );

    # version and variant
    substr( $uuid, 6, 1,
        chr( ( ord( substr( $uuid, 6, 1 ) ) & 0x0F ) | 0x70 ) );
    substr( $uuid, 8, 1,
        chr( ( ord( substr( $uuid, 8, 1 ) ) & 0x3F ) | 0x80 ) );

    return unpack( "H*", $uuid );
}

# based on https://github.com/perigrin/anthropophobia-heracliteanism
class World {
    use File::Slurper        qw(read_text);
    use File::ShareDir::Dist qw(dist_share);
    use JSON::MaybeXS        qw(encode_json decode_json);

    field $dsn :param = 'dbi:SQLite:dbname=:memory:';
    field $dbh = DBI->connect(
        $dsn, '', '',
        {
            PrintError                       => 0,
            RaiseError                       => 1,
            AutoCommit                       => 1,
            sqlite_allow_multiple_statements => 1,
        }
    );

    field @systems;

    ADJUST {
        $dbh->do(<<~'END_SQL') unless $dbh->tables > 2;
            CREATE TABLE IF NOT EXISTS entities (
                id TEXT PRIMARY KEY,
                label TEXT
            );
            CREATE TABLE IF NOT EXISTS components (
                id TEXT PRIMARY KEY,
                label TEXT UNIQUE NOT NULL,
                description TEXT
                FOREIGN KEY (id) REFERENCES entities(id)
            );
            CREATE TABLE IF NOT EXISTS entity_components (
                entity_id TEXT,
                component_id TEXT,
                component_data JSON,
                PRIMARY KEY (entity_id, component_id)
                FOREIGN KEY (entity_id) REFERENCES entities(id)
            );
        END_SQL
    }

    method new_entity($label) {
        my $uuid = uuid();
        $dbh->prepare_cached('INSERT INTO entities (id, label) VALUES(?, ?)')
          ->execute( $uuid, $label );
        return $uuid;
    }

    method destroy_entity($entity) {
        $dbh->prepare_cached(
            'DELETE FROM entity_components WHERE entity_id = ?')
          ->execute($entity);
        $dbh->prepare_cached('DELETE FROM entities WHERE id = ?')
          ->execute($entity);
    }

    method new_component_type( $label, $description, $ ) {
        my $uuid = uuid();
        my $sth  = $dbh->prepare_cached(<<~'END_SQL');
            INSERT OR IGNORE INTO components (id, label, description)
            VALUES(?, ?, ?)
        END_SQL
        $sth->execute( $uuid, $label, $description );
        return $uuid;
    }

    method get_id_for_component_type($type) {
        my $sth =
          $dbh->prepare_cached('SELECT id FROM components WHERE label = ?');
        return $dbh->selectcol_arrayref( $sth, {}, $type )->[0];
    }

    method add_component( $entity, $type, $data = {} ) {
        my $id  = $self->get_id_for_component_type($type);
        my $sth = $dbh->prepare_cached(<<~'END_SQL');
            INSERT INTO entity_components (entity_id, component_id, component_data)
            VALUES(?, ?, ?)
            ON CONFLICT
            DO UPDATE SET component_data = excluded.component_data
        END_SQL
        $sth->execute( $entity, $id, encode_json($data) );

    }

    method update_entity_component( $entity, $type, $data ) {
        my $sth = $dbh->prepare_cached(<<~'END_SQL');
            UPDATE entity_components
              SET component_data = ?
            WHERE entity_id = ?
              AND component_id in (SELECT id FROM components WHERE label = ?)
        END_SQL
        $sth->execute( encode_json($data), $entity, $type );
    }
    my sub placeholders($data) {
        \join ',', map '?', 0 .. ( ref $data ? @$data - 1 : 0 );
    }

    method get_components( $entity, @types ) {
        my $sth = $dbh->prepare_cached(<<~"END_SQL");
            SELECT ec.component_data 'data', c.label
             FROM entity_components ec
            INNER JOIN components c ON c.id = ec.component_id
            WHERE entity_id in (${placeholders($entity)})
              AND c.label in (${placeholders(\@types)})
        END_SQL
        $sth->execute( ref $entity ? @$entity : $entity, @types );
        my %components = map { $_->{label} => decode_json( $_->{data} ) }
          $sth->fetchall_arrayref( {} )->@*;
        return @components{@types};
    }

    method remove_components( $entity, @types ) {
        for my $type (@types) {
            my $id  = $self->get_id_for_component_type($type);
            my $sth = $dbh->prepare_cached(<<~'END_SQL');
                DELETE FROM entity_components
                WHERE entity_id = ? AND component_id = ?
            END_SQL
            $sth->execute( $entity, $id );
        }
    }

    use constant ENTITIES_FOR_COMPONENTS_SQL => <<~'END_SQL';
        SELECT ec.entity_id
        FROM entity_components ec
        INNER JOIN components c ON c.id = ec.component_id
    END_SQL

    method entites_for_components(@types) {
        my $sql = join "\nINTERSECT\n",
          map { ENTITIES_FOR_COMPONENTS_SQL . " WHERE c.label = ?" } @types;
        my $sth = $dbh->prepare_cached($sql);
        return $dbh->selectcol_arrayref( $sth, {}, @types )->@*;
    }

    method get_component_for_entities( $type, @entities ) {
        my $sth = $dbh->prepare_cached(<<~"END_SQL");
            SELECT ec.component_data 'data'
            FROM entity_components ec
            INNER JOIN components c ON c.id = ec.component_id
            INNER JOIN entities e ON e.id = ec.entity_id
            WHERE c.label = ? AND e.id in (${placeholders(\@entities)})
        END_SQL
        $sth->execute( $type, @entities );
        return map { decode_json( $_->{data} ) } $sth->selectall_arrayref()->@*;
    }

    method add_system($system) { push @systems, $system; }

    method remove_system($system) {
        @systems = grep { $_ ne $system } @systems;
    }

    method update() {
        for my $system (@systems) {
            my @components = $system->components_required;
            my @e          = $self->entites_for_components(@components);
            $system->set_entities(@e);
            $system->update( [ $self->get_components( \@e, @components ) ] );
        }
    }
}

class PlannerSystem {
    use builtin qw(false);

    field $world :param;

    ADJUST {
        $world->new_component_type(
            Goal => 'a goal for planning, has one or more conditions',
            {
                name       => 'goal',
                conditions => [],
                complete   => false,
            }
        );
        $world->new_component_type(
            Task => 'a task to complete a goal',
            {
                name                => 'a task',
                precondition_id     => 0,
                effect_condition_id => 0,
            }
        );
        $world->new_component_type(
            Todo => 'a task that needs to be done by an actor',
            {
                name => 'todo',
            }
        );
        $world->new_component_type(
            Condition => 'a condition to satisfy if a task is done',
            {
                name      => 'a condition',
                satisfied => false,
            }
        );
    }

    method add_goal( $actor, $goal, @conditions ) {
        $world->add_component(
            $actor, 'Goal',
            {
                name       => $goal,
                conditions => \@conditions,
                complete   => false
            }
        );
    }

    method add_task(
        $actor, $task,
        $action            = $task,
        $arguments         = [],
        $preconditions     = [],
        $effect_conditions = []
      )
    {
        $world->add_component(
            $actor, 'Task',
            {
                name              => $task,
                action            => $action,
                arguments         => $arguments,
                preconditions     => $preconditions,
                effect_conditions => $effect_conditions
            }
        );
    }

    method add_condition($condition) {
        my $entity = $world->new_entity($condition);
        $world->add_component(
            $condition,
            'Condition',
            {
                name      => $condition,
                satisfied => false
            }
        );
    }

    method get_conditions(@conditions) {
        return $world->get_component_for_entities( 'Condition', @conditions );
    }

    method make_plan(@conditions) {
        my @tasks = $world->get_component_for_entities( 'Task', @conditions );
        unshift @tasks,
          $self->make_plan(
            $self->get_conditions( map { $_->{preconditions}->@* } @tasks ) );
        return @tasks;
    }

    method complete_task( $actor, $task ) {

    }

    method update($data) {
        for my $actor ( $world->entites_for_components('Goal') ) {
            for my $goal ( $world->get_components( $actor, 'Goal' ) ) {
                my @conditions =
                  $self->get_conditions( $goal->{conditions}->@* );
                $goal->{complete} = all { $_->{satisfied} } @conditions;
                $world->update_entity_component( $actor, 'Goal', $goal );

                # TODO figure out the next task to complete our goal
                my @tasks =
                  $self->make_plan( grep { !$_->{satisfied} } @conditions );
                $self->add_task( $actor, @tasks );
            }
        }
    }
}
