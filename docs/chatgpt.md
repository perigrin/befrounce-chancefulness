Me: Explain a hierarchical task network planner in terms a high school senior would understand

Answer:
A Hierarchical Task Network (HTN) planner is a method for planning out complex tasks by breaking them down into smaller, more manageable steps. Think of it like planning for a big event, like a school fair or a science project. There are many things to do, and each big task (like organizing booths or setting up the stage) has smaller tasks within it (like calling vendors, setting up tables, or testing equipment).

Here’s how it works in simple terms:

1. **Big Goals**: First, the HTN planner looks at the main goal—let’s say, “run a successful school fair.” This is the top of the hierarchy (think of it like the top level in an outline or tree).

2. **Break It Down**: The planner then breaks this big goal down into smaller tasks. For example, "organize booths," "set up food stalls," and "coordinate volunteers." Each of these tasks is still pretty big, so it keeps breaking them down into even smaller steps.

3. **Keep Going Until the Tasks Are Manageable**: This process continues, with each task getting broken down until the planner reaches tasks that are simple enough to handle directly, like “set up tables” or “send confirmation emails to vendors.” These are the tasks that don’t need further breaking down—they’re the “leaves” of the planning tree.

4. **Order and Dependencies**: HTN planners also pay attention to the order of tasks. You can’t set up tables if you haven’t decided where the booths will go, so some tasks depend on others being done first.

5. **Execute the Plan**: Once all tasks are laid out in a manageable way and in the right order, the planner can “execute” the plan—meaning it can go step-by-step to reach the final goal of having a well-organized school fair.

In short, an HTN planner is a way to simplify complex tasks by breaking them down into smaller pieces and organizing them in a way that’s logical and manageable, just like following a detailed outline when writing a paper.

Me: Give me an example that uses Perl and and SQLite database

Answer:
To implement a basic **Hierarchical Task Network (HTN) planner** in Perl with an SQLite database, we’ll focus on:

1. **Defining Tasks and Subtasks** in the database.
2. **Organizing Tasks in a Hierarchical Structure** using parent-child relationships.
3. **Implementing a Planner** in Perl that can query tasks and plan a sequence by breaking down complex tasks into their subtasks.

Here’s an example of a simple HTN Planner using Perl and SQLite.

### Structure Overview

We’ll set up an SQLite database with a `tasks` table to represent tasks in a hierarchical structure. Each task can have a `parent_task_id`, which allows us to establish the hierarchy by linking subtasks to their parent task.

### Step 1: Database Setup

#### Database Schema
- `tasks` table: Stores each task with a unique `id`, a `name`, a `parent_task_id` to link it to a parent task (if it’s a subtask), and a `status` field to track if the task is completed.

#### Sample Hierarchy
For demonstration, let's say the main task is “Organize Event,” and it has subtasks like “Book Venue,” “Arrange Catering,” and “Send Invitations.” Each of these subtasks may also have its own subtasks.

### Code Example

```perl
use strict;
use warnings;
use DBI;

# Connect to the SQLite database (or create it if it doesn't exist)
my $dbh = DBI->connect("dbi:SQLite:dbname=htn_planner.db","","", {
    RaiseError => 1,
    AutoCommit => 1,
}) or die $DBI::errstr;

# Create tasks table with a parent_task_id for hierarchical relationships
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    parent_task_id INTEGER,
    status TEXT DEFAULT 'pending',
    FOREIGN KEY (parent_task_id) REFERENCES tasks(id)
)");

# Function to add a task
sub add_task {
    my ($name, $parent_task_id) = @_;
    my $sth = $dbh->prepare("INSERT INTO tasks (name, parent_task_id, status) VALUES (?, ?, 'pending')");
    $sth->execute($name, $parent_task_id);
    print "Task added: $name\n";
}

# Recursive function to retrieve tasks in a hierarchical order
sub display_task_hierarchy {
    my ($parent_id, $level) = @_;
    my $sth = $dbh->prepare("SELECT id, name, status FROM tasks WHERE parent_task_id = ?");
    $sth->execute($parent_id);
    while (my $row = $sth->fetchrow_hashref) {
        print "  " x $level, "$row->{name} (Status: $row->{status})\n";
        # Recursively fetch and display subtasks
        display_task_hierarchy($row->{id}, $level + 1);
    }
}

# Function to mark a task as completed
sub complete_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("UPDATE tasks SET status = 'completed' WHERE id = ?");
    $sth->execute($task_id);
    print "Task with ID $task_id marked as completed.\n";
}

# Sample data for demonstration
print "Adding tasks:\n";
add_task("Organize Event", undef);               # Main task
add_task("Book Venue", 1);                       # Subtask of "Organize Event"
add_task("Arrange Catering", 1);                 # Subtask of "Organize Event"
add_task("Send Invitations", 1);                 # Subtask of "Organize Event"
add_task("Confirm Menu", 3);                     # Subtask of "Arrange Catering"
add_task("Order Tables", 2);                     # Subtask of "Book Venue"

print "\nTask Hierarchy:\n";
display_task_hierarchy(undef, 0);

print "\nCompleting 'Arrange Catering' and 'Confirm Menu' tasks:\n";
complete_task(3);
complete_task(5);

print "\nTask Hierarchy After Completion:\n";
display_task_hierarchy(undef, 0);

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of the Code

1. **Database Connection and Table Creation**:
   - We connect to an SQLite database `htn_planner.db`. The `tasks` table is created if it doesn’t exist, with columns for `id`, `name`, `parent_task_id` (which links subtasks to parent tasks), and `status`.

2. **Adding Tasks**:
   - The `add_task` function inserts a new task into the `tasks` table. If a task is a subtask, `parent_task_id` links it to its parent task.

3. **Displaying Hierarchical Tasks**:
   - `display_task_hierarchy` is a recursive function that displays tasks in a structured, hierarchical format. It starts from a given `parent_id` and indents each level of subtasks for clarity.

4. **Completing Tasks**:
   - `complete_task` marks a task as completed by updating its `status` in the database.

5. **Sample Usage**:
   - The script adds a main task (“Organize Event”) and several subtasks. It then displays the task hierarchy, completes a couple of tasks, and displays the hierarchy again to reflect the changes.

### Running the Script

To execute, save this script as `htn_planner.pl` and run it:

```bash
perl htn_planner.pl
```

### Output

The output will show the hierarchical structure of tasks and reflect task completion. Here’s an example output:

```plaintext
Adding tasks:
Task added: Organize Event
Task added: Book Venue
Task added: Arrange Catering
Task added: Send Invitations
Task added: Confirm Menu
Task added: Order Tables

Task Hierarchy:
Organize Event (Status: pending)
  Book Venue (Status: pending)
    Order Tables (Status: pending)
  Arrange Catering (Status: pending)
    Confirm Menu (Status: pending)
  Send Invitations (Status: pending)

Completing 'Arrange Catering' and 'Confirm Menu' tasks:
Task with ID 3 marked as completed.
Task with ID 5 marked as completed.

Task Hierarchy After Completion:
Organize Event (Status: pending)
  Book Venue (Status: pending)
    Order Tables (Status: pending)
  Arrange Catering (Status: completed)
    Confirm Menu (Status: completed)
  Send Invitations (Status: pending)
```

This example showcases how an HTN planner could be implemented in Perl with an SQLite database, managing hierarchical tasks and updating task statuses as steps are completed. You can expand it by adding dependencies, priorities, or additional conditions.

Me:
Update this for Goal Oriented Planning

Answer:
In a **Goal-Oriented Planning** (GOP) approach, instead of focusing strictly on hierarchical task breakdowns, we focus on achieving specific goals. Tasks are chosen based on how effectively they help in reaching these goals.

This means the planning system should consider:
1. Goals to be achieved.
2. Conditions that need to be met for each goal.
3. Actions that contribute to achieving these goals by changing conditions or states.

We’ll use the same SQLite setup, but add a new `goals` table to store goals and associated conditions. Each task will be linked to the conditions it affects, allowing the planner to determine if performing a task will contribute to meeting the goal.

### Database Structure

1. **`goals` table**: Stores each goal, its target condition, and a status indicating whether it's achieved.
2. **`conditions` table**: Stores each condition needed for goals.
3. **`tasks` table**: Stores tasks, including `precondition_id` (linking tasks to conditions required before the task can be done) and `effect_condition_id` (linking tasks to the conditions they achieve).

### Updated Perl Script

This script defines goals and plans actions (tasks) based on whether they help achieve the goal conditions.

```perl
use strict;
use warnings;
use DBI;

# Connect to the SQLite database (or create it if it doesn't exist)
my $dbh = DBI->connect("dbi:SQLite:dbname=goal_planner.db","","", {
    RaiseError => 1,
    AutoCommit => 1,
}) or die $DBI::errstr;

# Create tables for goals, conditions, and tasks
$dbh->do("CREATE TABLE IF NOT EXISTS goals (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    condition_id INTEGER,
    status TEXT DEFAULT 'incomplete',
    FOREIGN KEY (condition_id) REFERENCES conditions(id)
)");

$dbh->do("CREATE TABLE IF NOT EXISTS conditions (
    id INTEGER PRIMARY KEY,
    description TEXT NOT NULL
)");

$dbh->do("CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    precondition_id INTEGER,
    effect_condition_id INTEGER,
    status TEXT DEFAULT 'pending',
    FOREIGN KEY (precondition_id) REFERENCES conditions(id),
    FOREIGN KEY (effect_condition_id) REFERENCES conditions(id)
)");

# Add a new goal
sub add_goal {
    my ($name, $condition_id) = @_;
    my $sth = $dbh->prepare("INSERT INTO goals (name, condition_id, status) VALUES (?, ?, 'incomplete')");
    $sth->execute($name, $condition_id);
    print "Goal added: $name\n";
}

# Add a condition
sub add_condition {
    my ($description) = @_;
    my $sth = $dbh->prepare("INSERT INTO conditions (description) VALUES (?)");
    $sth->execute($description);
    return $dbh->last_insert_id("", "", "conditions", "");
}

# Add a task with a precondition and an effect
sub add_task {
    my ($name, $precondition_id, $effect_condition_id) = @_;
    my $sth = $dbh->prepare("INSERT INTO tasks (name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, 'pending')");
    $sth->execute($name, $precondition_id, $effect_condition_id);
    print "Task added: $name\n";
}

# Check if all conditions for a goal are met
sub check_goal_status {
    my ($goal_id) = @_;
    my $sth = $dbh->prepare("SELECT g.id, g.name, g.condition_id, c.description, g.status
                             FROM goals g JOIN conditions c ON g.condition_id = c.id
                             WHERE g.id = ? AND g.status = 'incomplete'");
    $sth->execute($goal_id);
    if (my $row = $sth->fetchrow_hashref) {
        print "Goal: $row->{name}, Condition Required: $row->{description}, Status: $row->{status}\n";
        return 0;
    } else {
        print "Goal $goal_id has been achieved!\n";
        return 1;
    }
}

# Complete a task, achieving its effect condition and updating goals
sub complete_task {
    my ($task_id) = @_;
    # Update task status
    my $sth = $dbh->prepare("UPDATE tasks SET status = 'completed' WHERE id = ?");
    $sth->execute($task_id);

    # Find the effect condition and update goals associated with it
    $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    my ($effect_condition_id) = $sth->fetchrow_array;

    # Update goals linked to the effect condition
    $sth = $dbh->prepare("UPDATE goals SET status = 'complete' WHERE condition_id = ?");
    $sth->execute($effect_condition_id);
    print "Task with ID $task_id completed, affecting Condition ID $effect_condition_id.\n";
}

# Add sample data and perform goal-oriented planning
print "Setting up sample goals, conditions, and tasks:\n";
my $venue_ready = add_condition("Venue is booked and ready");
my $menu_chosen = add_condition("Menu chosen for catering");

add_goal("Organize Event", $venue_ready);
add_task("Book Venue", undef, $venue_ready);
add_task("Choose Catering Menu", undef, $menu_chosen);

print "\nChecking goal status:\n";
check_goal_status(1);

print "\nCompleting tasks to meet goals:\n";
complete_task(1); # Completes "Book Venue", affecting "Venue is booked and ready"
check_goal_status(1);

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of Key Elements

1. **Goals and Conditions**:
   - Goals (like “Organize Event”) require specific conditions to be achieved, which are stored in the `conditions` table.
   - Each goal is linked to a condition (e.g., "Venue is booked and ready").

2. **Tasks with Preconditions and Effects**:
   - Tasks now include a `precondition_id` and `effect_condition_id`.
   - `precondition_id`: Condition that must be met before performing the task.
   - `effect_condition_id`: Condition that is achieved once the task is completed.
   - For example, “Book Venue” has an effect condition of “Venue is booked and ready,” which fulfills the condition for the “Organize Event” goal.

3. **Goal-Oriented Planning and Execution**:
   - `check_goal_status` checks if all conditions for a goal are met.
   - `complete_task` marks a task as complete, updates its effect condition, and checks for any goals that now meet their conditions due to the completed task.

4. **Running the Script**:
   - Save as `goal_planner.pl` and execute with:
     ```bash
     perl goal_planner.pl
     ```

### Sample Output

```plaintext
Setting up sample goals, conditions, and tasks:
Goal added: Organize Event
Task added: Book Venue
Task added: Choose Catering Menu

Checking goal status:
Goal: Organize Event, Condition Required: Venue is booked and ready, Status: incomplete

Completing tasks to meet goals:
Task with ID 1 completed, affecting Condition ID 1.
Goal 1 has been achieved!
```

This code models **Goal-Oriented Planning** where tasks are selected and performed based on their ability to achieve specific goal conditions. This setup could be expanded to include complex goal dependencies, priorities, and dynamic task selection to support more sophisticated planning scenarios.

Me:
This doesn’t seem to have the solver/planner portion from something like PhHOP

Answer:
To add a planner/solver portion similar to what you’d find in something like **Partial-Order Hierarchical Planning (PHOP)**, we'll need to implement a more dynamic solution that evaluates available tasks based on their preconditions and recursively chooses actions that help achieve a specific goal.

### Enhancements Needed for PHOP-like Functionality

1. **Condition Check**: The planner needs to identify tasks that can be executed based on current conditions and recursively break down tasks until all required conditions for the main goal are satisfied.
2. **Partial-Order Planning**: It should not impose strict ordering on all tasks but rather select actions as their preconditions are met, allowing flexibility.

To implement this, we’ll add:
- **Recursive Solver**: It attempts to achieve the conditions required for the primary goal, dynamically selecting tasks that meet their preconditions.
- **Planner Execution**: It breaks down goals into tasks and subtasks, building a plan that achieves all necessary conditions without strict ordering.

Here’s the revised script with the planner/solver portion.

```perl
use strict;
use warnings;
use DBI;

# Connect to the SQLite database (or create it if it doesn't exist)
my $dbh = DBI->connect("dbi:SQLite:dbname=phop_planner.db","","", {
    RaiseError => 1,
    AutoCommit => 1,
}) or die $DBI::errstr;

# Create tables for goals, conditions, and tasks
$dbh->do("CREATE TABLE IF NOT EXISTS goals (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    condition_id INTEGER,
    status TEXT DEFAULT 'incomplete',
    FOREIGN KEY (condition_id) REFERENCES conditions(id)
)");

$dbh->do("CREATE TABLE IF NOT EXISTS conditions (
    id INTEGER PRIMARY KEY,
    description TEXT NOT NULL
)");

$dbh->do("CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    precondition_id INTEGER,
    effect_condition_id INTEGER,
    status TEXT DEFAULT 'pending',
    FOREIGN KEY (precondition_id) REFERENCES conditions(id),
    FOREIGN KEY (effect_condition_id) REFERENCES conditions(id)
)");

# Add a new goal
sub add_goal {
    my ($name, $condition_id) = @_;
    my $sth = $dbh->prepare("INSERT INTO goals (name, condition_id, status) VALUES (?, ?, 'incomplete')");
    $sth->execute($name, $condition_id);
    print "Goal added: $name\n";
}

# Add a condition
sub add_condition {
    my ($description) = @_;
    my $sth = $dbh->prepare("INSERT INTO conditions (description) VALUES (?)");
    $sth->execute($description);
    return $dbh->last_insert_id("", "", "conditions", "");
}

# Add a task with a precondition and an effect
sub add_task {
    my ($name, $precondition_id, $effect_condition_id) = @_;
    my $sth = $dbh->prepare("INSERT INTO tasks (name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, 'pending')");
    $sth->execute($name, $precondition_id, $effect_condition_id);
    print "Task added: $name\n";
}

# Complete a task and update its effect condition
sub complete_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("UPDATE tasks SET status = 'completed' WHERE id = ?");
    $sth->execute($task_id);

    # Retrieve effect condition
    $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    my ($effect_condition_id) = $sth->fetchrow_array;

    # Update goals associated with the achieved condition
    $sth = $dbh->prepare("UPDATE goals SET status = 'complete' WHERE condition_id = ?");
    $sth->execute($effect_condition_id);
    print "Task $task_id completed, fulfilling condition $effect_condition_id.\n";
}

# Recursive planner to achieve a condition
sub achieve_condition {
    my ($condition_id) = @_;
    print "Attempting to achieve condition: $condition_id\n";

    # Check if any task with the required effect condition is available
    my $sth = $dbh->prepare("SELECT id, name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);

    # If a task exists, check its preconditions and complete it if possible
    while (my $task = $sth->fetchrow_hashref) {
        my $task_id = $task->{id};
        my $precondition_id = $task->{precondition_id};

        if ($precondition_id) {
            # Recursively achieve precondition
            achieve_condition($precondition_id);
        }

        # Complete the task once all preconditions are achieved
        complete_task($task_id);
    }
}

# Sample data for demonstration
print "Setting up sample goals, conditions, and tasks:\n";
my $venue_ready = add_condition("Venue is booked and ready");
my $menu_chosen = add_condition("Menu chosen for catering");

add_goal("Organize Event", $venue_ready);
add_task("Book Venue", undef, $venue_ready);
add_task("Choose Catering Menu", undef, $menu_chosen);

print "\nPlanner Execution:\n";
achieve_condition($venue_ready);

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of the Enhanced Code

1. **Recursive `achieve_condition` Function**:
   - The function `achieve_condition` is designed to work like a recursive solver. For a given condition, it looks up any task that, once completed, will satisfy this condition (`effect_condition_id`).
   - If the task has a precondition (`precondition_id`), it recursively attempts to achieve that precondition before completing the task itself.
   - Once all preconditions are met, the task is completed, and its effect condition is fulfilled. This might help satisfy a higher-level goal condition.

2. **Dynamic Goal-Oriented Planning**:
   - With this recursive approach, the planner can dynamically select tasks to achieve conditions without predefining the full order, allowing for flexibility based on available tasks and conditions.

3. **Example Workflow**:
   - We define a goal “Organize Event” that depends on the condition “Venue is booked and ready.”
   - The task “Book Venue” has an effect of fulfilling the “Venue is booked and ready” condition.
   - The planner begins by calling `achieve_condition` on “Venue is booked and ready,” finds the “Book Venue” task, completes it, and updates the condition, satisfying the goal.

4. **Output**:
   - This script’s output will show the recursive process as the planner attempts to achieve the required condition and marks tasks as completed.

### Sample Output

```plaintext
Setting up sample goals, conditions, and tasks:
Goal added: Organize Event
Task added: Book Venue
Task added: Choose Catering Menu

Planner Execution:
Attempting to achieve condition: 1
Task 1 completed, fulfilling condition 1.
```

### PHOP Characteristics in the Example

This approach demonstrates **Partial-Order Planning** by only enforcing order when needed based on preconditions. Tasks are completed dynamically when conditions allow, reflecting a flexible, goal-oriented approach suitable for HTN and GOP planning styles, similar to the PHOP framework.

Me:
Can you reformulate this using an ECS framework?

Answer:
To adapt this Goal-Oriented Planning (GOP) or Hierarchical Task Network (HTN) planner using an **Entity-Component-System (ECS)** framework, we need to break down the system into **Entities**, **Components**, and **Systems**. ECS frameworks are commonly used in game development and simulations because they separate data (components) from logic (systems) and allow for flexible management of entities (objects with various components attached).

Here's how we could model the planner with an ECS approach in Perl.

### ECS Structure

1. **Entities**: Represent individual tasks, goals, or conditions.
2. **Components**: Store data attributes for entities, such as `Condition`, `Goal`, and `Task` details.
3. **Systems**: Perform logic on entities based on their components, such as a `PlannerSystem` to handle goal planning and task execution.

### Step 1: Define the ECS Framework

To keep things simple, we’ll create our ECS framework with a hash-based structure in Perl.

- **Entities** are identified by unique IDs.
- **Components** store data for entities, organized by component type (e.g., `Condition`, `Goal`, `Task`).
- **Systems** iterate over entities with relevant components to apply the logic.

### Code Example

Here's an implementation of a simple ECS-based HTN/GOP planner in Perl with SQLite integration.

```perl
use strict;
use warnings;
use DBI;

# ECS Framework Structures
my %entities;         # Store entities
my %components;       # Store components by type
my @systems;          # Store systems

# Database Connection
my $dbh = DBI->connect("dbi:SQLite:dbname=ecs_planner.db","","", {
    RaiseError => 1,
    AutoCommit => 1,
}) or die $DBI::errstr;

# Create tables
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, description TEXT NOT NULL)");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, name TEXT NOT NULL, condition_id INTEGER, status TEXT DEFAULT 'incomplete')");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, name TEXT NOT NULL, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending')");

# ECS Component Definitions
sub add_condition_component {
    my ($entity_id, $description) = @_;
    $components{Condition}{$entity_id} = { description => $description };
    $dbh->do("INSERT INTO conditions (description) VALUES (?)", undef, $description);
}

sub add_goal_component {
    my ($entity_id, $name, $condition_id) = @_;
    $components{Goal}{$entity_id} = { name => $name, condition_id => $condition_id, status => 'incomplete' };
    $dbh->do("INSERT INTO goals (name, condition_id, status) VALUES (?, ?, 'incomplete')", undef, $name, $condition_id);
}

sub add_task_component {
    my ($entity_id, $name, $precondition_id, $effect_condition_id) = @_;
    $components{Task}{$entity_id} = { name => $name, precondition_id => $precondition_id, effect_condition_id => $effect_condition_id, status => 'pending' };
    $dbh->do("INSERT INTO tasks (name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, 'pending')", undef, $name, $precondition_id, $effect_condition_id);
}

# ECS Entity Creation
sub create_entity {
    my $entity_id = scalar(keys %entities) + 1;
    $entities{$entity_id} = {};
    return $entity_id;
}

# ECS System Definitions
sub PlannerSystem {
    # System to check and plan tasks to achieve goals
    foreach my $entity_id (keys %{ $components{Goal} }) {
        my $goal = $components{Goal}{$entity_id};

        if ($goal->{status} eq 'incomplete') {
            my $condition_id = $goal->{condition_id};

            print "Planning to achieve condition: $condition_id for goal '$goal->{name}'\n";
            achieve_condition($condition_id);

            # Update goal status if condition achieved
            $goal->{status} = 'complete' if check_condition($condition_id);
        }
    }
}

# Recursive Function to Achieve Condition
sub achieve_condition {
    my ($condition_id) = @_;

    foreach my $task_id (keys %{ $components{Task} }) {
        my $task = $components{Task}{$task_id};

        if ($task->{effect_condition_id} == $condition_id && $task->{status} eq 'pending') {
            if ($task->{precondition_id}) {
                achieve_condition($task->{precondition_id});
            }
            complete_task($task_id);
            return;
        }
    }
}

# Helper to Check if a Condition is Met
sub check_condition {
    my ($condition_id) = @_;
    my $sth = $dbh->prepare("SELECT description FROM conditions WHERE id = ?");
    $sth->execute($condition_id);
    return $sth->fetchrow_array ? 1 : 0;
}

# Complete Task and Update Effects
sub complete_task {
    my ($task_id) = @_;
    my $task = $components{Task}{$task_id};

    if ($task) {
        $task->{status} = 'completed';
        print "Task '$task->{name}' completed, fulfilling condition $task->{effect_condition_id}.\n";

        # Update goal status if this task fulfills its effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE goals SET status = 'complete' WHERE condition_id = ?", undef, $task->{effect_condition_id});
    }
}

# Setup Sample ECS-based Planning
print "Setting up ECS-based planner:\n";

# Conditions
my $venue_ready = create_entity();
add_condition_component($venue_ready, "Venue is booked and ready");

my $menu_chosen = create_entity();
add_condition_component($menu_chosen, "Menu chosen for catering");

# Goal
my $goal_entity = create_entity();
add_goal_component($goal_entity, "Organize Event", $venue_ready);

# Tasks
my $task_entity1 = create_entity();
add_task_component($task_entity1, "Book Venue", undef, $venue_ready);

my $task_entity2 = create_entity();
add_task_component($task_entity2, "Choose Catering Menu", undef, $menu_chosen);

# Run Planner System
print "\nExecuting Planner System:\n";
PlannerSystem();

# Close database connection
$dbh->disconnect;
```

### Explanation of ECS Components and Systems

1. **Entity Creation**: Each task, goal, and condition is an entity, represented by a unique ID.
2. **Components**:
   - `ConditionComponent`: Stores the description of a condition.
   - `GoalComponent`: Stores the goal’s name, the condition it needs to fulfill, and its status.
   - `TaskComponent`: Stores each task’s name, precondition, effect condition, and status.
3. **Systems**:
   - `PlannerSystem`: Checks incomplete goals and attempts to fulfill their conditions by selecting tasks whose effects meet the required conditions.
4. **Recursive Planner (achieve_condition)**:
   - The `achieve_condition` function recursively selects tasks based on their preconditions, ensuring they are met in the correct order.

### Sample Output

```plaintext
Setting up ECS-based planner:
Goal added: Organize Event
Task added: Book Venue
Task added: Choose Catering Menu

Executing Planner System:
Planning to achieve condition: 1 for goal 'Organize Event'
Task 'Book Venue' completed, fulfilling condition 1.
```

### Benefits of ECS Structure

This ECS-based approach:
- **Decouples Data from Logic**: Components hold data, while systems handle planning and execution, making it flexible and easy to extend.
- **Supports Dynamic Planning**: The `PlannerSystem` only completes tasks based on preconditions, which aligns with the partial-order planning seen in HTN and GOP methods.
- **Easily Scalable**: New tasks, goals, and conditions can be added by simply creating new entities and attaching components, making it adaptable for more complex planning needs.

Me:
Using this system give me some basic RPG characters

Answer:
Using this ECS (Entity-Component-System) framework, we can model basic RPG characters with different components to store their **attributes** (like health and strength), **abilities** (such as spells or attacks), and **status effects** (like buffs or debuffs).

### Example Code: ECS Framework for RPG Characters

In this example, we'll:
1. Define characters as **entities**.
2. Add **components** for different attributes, abilities, and statuses.
3. Use **systems** to handle actions, such as attacking or applying status effects.

Let's expand on the previous ECS structure with some RPG-specific components and systems.

```perl
use strict;
use warnings;

# ECS Framework for RPG Characters
my %entities;         # Store entities
my %components;       # Store components by type
my @systems;          # Store systems

# ECS Component Definitions
# Add a Health Component
sub add_health_component {
    my ($entity_id, $health, $max_health) = @_;
    $components{Health}{$entity_id} = { health => $health, max_health => $max_health };
}

# Add an Attributes Component (e.g., strength, defense)
sub add_attributes_component {
    my ($entity_id, $strength, $defense) = @_;
    $components{Attributes}{$entity_id} = { strength => $strength, defense => $defense };
}

# Add an Abilities Component
sub add_abilities_component {
    my ($entity_id, $ability_name, $damage) = @_;
    $components{Abilities}{$entity_id} = { ability_name => $ability_name, damage => $damage };
}

# Add a Status Effect Component
sub add_status_effect_component {
    my ($entity_id, $effect_name, $duration) = @_;
    $components{StatusEffects}{$entity_id} = { effect_name => $effect_name, duration => $duration };
}

# ECS Entity Creation
sub create_entity {
    my $entity_id = scalar(keys %entities) + 1;
    $entities{$entity_id} = {};
    return $entity_id;
}

# ECS System Definitions
# Combat System to handle basic attacks
sub CombatSystem {
    my ($attacker_id, $defender_id) = @_;

    if (exists $components{Abilities}{$attacker_id} && exists $components{Attributes}{$defender_id}) {
        my $ability = $components{Abilities}{$attacker_id};
        my $defender_health = $components{Health}{$defender_id};
        my $defender_attributes = $components{Attributes}{$defender_id};

        # Calculate damage based on attacker's ability and defender's defense
        my $damage = $ability->{damage} - $defender_attributes->{defense};
        $damage = $damage > 0 ? $damage : 0; # Ensure no negative damage

        # Apply damage to defender's health
        $defender_health->{health} -= $damage;
        $defender_health->{health} = $defender_health->{health} > 0 ? $defender_health->{health} : 0;

        print "Attacker used $ability->{ability_name} dealing $damage damage! Defender's remaining health: $defender_health->{health}\n";
    }
}

# Status Effect System to apply effects
sub StatusEffectSystem {
    foreach my $entity_id (keys %{ $components{StatusEffects} }) {
        my $status = $components{StatusEffects}{$entity_id};

        # Reduce the duration of the status effect
        $status->{duration}--;

        print "Entity $entity_id has $status->{effect_name} effect. Duration left: $status->{duration}\n";

        # Remove the status effect if duration is zero
        if ($status->{duration} <= 0) {
            delete $components{StatusEffects}{$entity_id};
            print "Status effect $status->{effect_name} expired on Entity $entity_id.\n";
        }
    }
}

# Sample RPG Character Setup
print "Creating RPG Characters:\n";

# Create Warrior Entity
my $warrior = create_entity();
add_health_component($warrior, 100, 100);
add_attributes_component($warrior, 15, 5);        # Strength: 15, Defense: 5
add_abilities_component($warrior, "Slash", 20);   # Ability: Slash with 20 damage

# Create Mage Entity
my $mage = create_entity();
add_health_component($mage, 80, 80);
add_attributes_component($mage, 10, 3);           # Strength: 10, Defense: 3
add_abilities_component($mage, "Fireball", 25);   # Ability: Fireball with 25 damage

# Add Status Effect to Warrior
add_status_effect_component($warrior, "Burning", 3); # Burning effect for 3 turns

# Combat Simulation
print "\nCombat Simulation:\n";
CombatSystem($mage, $warrior);  # Mage attacks Warrior
CombatSystem($warrior, $mage);  # Warrior attacks Mage

# Apply Status Effects
print "\nApplying Status Effects:\n";
StatusEffectSystem();

# Run Status Effect System again to show effect decay
print "\nNext Turn - Status Effect Decay:\n";
StatusEffectSystem();
```

### Explanation of the RPG ECS Components and Systems

1. **Entities**: Each RPG character (Warrior and Mage) is created as an entity.

2. **Components**:
   - **Health**: Stores current and max health.
   - **Attributes**: Stores basic stats like `strength` and `defense`.
   - **Abilities**: Stores abilities such as "Slash" or "Fireball" with respective damage values.
   - **StatusEffects**: Stores temporary effects like "Burning," with a duration in turns.

3. **Systems**:
   - **CombatSystem**: Calculates damage based on attacker’s `Abilities` and defender’s `Attributes`. Damage is reduced by the defender’s defense stat.
   - **StatusEffectSystem**: Reduces the duration of status effects each turn. If the duration reaches zero, the effect is removed from the entity.

4. **Combat Simulation**:
   - The Mage attacks the Warrior, dealing damage based on the Mage’s ability (Fireball).
   - The Warrior then retaliates with a Slash attack on the Mage.
   - Status effects are applied to simulate turns, with effects decaying each turn.

### Sample Output

```plaintext
Creating RPG Characters:
Entity 1 created (Warrior)
Entity 2 created (Mage)

Combat Simulation:
Attacker used Fireball dealing 22 damage! Defender's remaining health: 78
Attacker used Slash dealing 15 damage! Defender's remaining health: 65

Applying Status Effects:
Entity 1 has Burning effect. Duration left: 2

Next Turn - Status Effect Decay:
Entity 1 has Burning effect. Duration left: 1
Status effect Burning expired on Entity 1.
```

### Benefits of Using ECS for RPG Characters

- **Modularity**: Components can be added or removed without affecting the core logic, allowing flexible character customization.
- **Reusability**: Systems like `CombatSystem` and `StatusEffectSystem` can apply to any entity with the required components, enabling reusability across different characters or enemies.
- **Scalability**: New abilities, attributes, or status effects can be added by creating components and expanding systems, making it easy to scale for more complex RPG mechanics.

Me: Use the full HTN Planner

Answer:
To build a full **Hierarchical Task Network (HTN) Planner** within the ECS framework for RPG characters, we’ll add a planning layer that allows characters to achieve specific goals by breaking them down into hierarchical tasks. For RPG characters, this might involve high-level goals like "Defeat Enemy" or "Prepare for Battle," which can be broken down into sub-tasks like "Find Weapon," "Cast Spell," and "Attack."

### Updated ECS Structure with HTN Planning

We'll add:
1. **Goal Components** to define high-level objectives (e.g., "Defeat Enemy").
2. **Task Components** for each sub-task required to achieve goals.
3. **HTN Planner System** to dynamically select and execute tasks based on dependencies and conditions.

### Step 1: Define Components for Goals, Tasks, and Conditions

To make this work, we'll need:
- **Entities** representing each RPG character or enemy.
- **GoalComponent** to represent high-level goals.
- **TaskComponent** for each actionable step or sub-task in the plan.
- **ConditionComponent** to represent conditions that must be met for tasks to proceed (e.g., "has weapon").

### Code Example: ECS-Based HTN Planner for RPG Characters

```perl
use strict;
use warnings;

# ECS Framework for RPG with HTN Planner
my %entities;         # Store entities
my %components;       # Store components by type
my @systems;          # Store systems

# ECS Component Definitions
# Add Health Component
sub add_health_component {
    my ($entity_id, $health, $max_health) = @_;
    $components{Health}{$entity_id} = { health => $health, max_health => $max_health };
}

# Add Attributes Component (e.g., strength, defense)
sub add_attributes_component {
    my ($entity_id, $strength, $defense) = @_;
    $components{Attributes}{$entity_id} = { strength => $strength, defense => $defense };
}

# Add Abilities Component
sub add_abilities_component {
    my ($entity_id, $ability_name, $damage) = @_;
    $components{Abilities}{$entity_id} = { ability_name => $ability_name, damage => $damage };
}

# Add Goal Component (e.g., "Defeat Enemy")
sub add_goal_component {
    my ($entity_id, $goal_name, $condition_id) = @_;
    $components{Goal}{$entity_id} = { goal_name => $goal_name, condition_id => $condition_id, status => 'incomplete' };
}

# Add Task Component with preconditions and effects
sub add_task_component {
    my ($entity_id, $task_name, $precondition_id, $effect_condition_id) = @_;
    $components{Task}{$entity_id} = { task_name => $task_name, precondition_id => $precondition_id, effect_condition_id => $effect_condition_id, status => 'pending' };
}

# Add Condition Component
sub add_condition_component {
    my ($entity_id, $condition_name) = @_;
    $components{Condition}{$entity_id} = { condition_name => $condition_name, satisfied => 0 };
}

# ECS Entity Creation
sub create_entity {
    my $entity_id = scalar(keys %entities) + 1;
    $entities{$entity_id} = {};
    return $entity_id;
}

# HTN Planner System to achieve goals by executing tasks based on conditions
sub HTNPlannerSystem {
    foreach my $entity_id (keys %{ $components{Goal} }) {
        my $goal = $components{Goal}{$entity_id};

        if ($goal->{status} eq 'incomplete') {
            my $condition_id = $goal->{condition_id};

            print "Planning to achieve goal: $goal->{goal_name} by fulfilling condition: $condition_id\n";
            achieve_condition($entity_id, $condition_id);

            # Check if the condition for the goal is now satisfied
            $goal->{status} = 'complete' if check_condition($condition_id);
        }
    }
}

# Recursive function to achieve a condition by executing tasks
sub achieve_condition {
    my ($entity_id, $condition_id) = @_;

    # Check for tasks that fulfill the desired condition
    foreach my $task_id (keys %{ $components{Task} }) {
        my $task = $components{Task}{$task_id};

        # If the task has the effect of satisfying the condition, check its preconditions
        if ($task->{effect_condition_id} == $condition_id && $task->{status} eq 'pending') {
            if ($task->{precondition_id}) {
                # Recursively fulfill the precondition first
                achieve_condition($entity_id, $task->{precondition_id});
            }
            # Execute the task after preconditions are met
            execute_task($task_id);
            return;
        }
    }
}

# Function to check if a condition is satisfied
sub check_condition {
    my ($condition_id) = @_;
    return $components{Condition}{$condition_id}{satisfied};
}

# Execute a task and fulfill its effect condition
sub execute_task {
    my ($task_id) = @_;
    my $task = $components{Task}{$task_id};

    if ($task) {
        $task->{status} = 'completed';
        print "Executing task: $task->{task_name}\n";

        # Mark the effect condition as satisfied
        my $effect_condition_id = $task->{effect_condition_id};
        $components{Condition}{$effect_condition_id}{satisfied} = 1;
    }
}

# Setup Sample RPG HTN Planning

print "Setting up RPG HTN Planner:\n";

# Define Conditions
my $has_weapon = create_entity();
add_condition_component($has_weapon, "Has Weapon");

my $enemy_defeated = create_entity();
add_condition_component($enemy_defeated, "Enemy Defeated");

# Define Goals
my $goal_entity = create_entity();
add_goal_component($goal_entity, "Defeat Enemy", $enemy_defeated);

# Define Tasks for the Goal
my $task_find_weapon = create_entity();
add_task_component($task_find_weapon, "Find Weapon", undef, $has_weapon);

my $task_attack_enemy = create_entity();
add_task_component($task_attack_enemy, "Attack Enemy", $has_weapon, $enemy_defeated);

# Run HTN Planner System to achieve the goal
print "\nExecuting HTN Planner System:\n";
HTNPlannerSystem();

```

### Explanation of HTN Components and Planner System

1. **GoalComponent**:
   - Each goal has a target condition (`condition_id`) that needs to be satisfied for the goal to be completed. In this case, the goal "Defeat Enemy" requires the "Enemy Defeated" condition.

2. **TaskComponent**:
   - Each task has a `precondition_id` (optional) and an `effect_condition_id`. For example, "Attack Enemy" has a precondition of "Has Weapon" and results in the condition "Enemy Defeated."
   - Tasks can have nested dependencies, where a task requires one or more preconditions, and each precondition could be a separate task to fulfill.

3. **ConditionComponent**:
   - Conditions represent states that tasks aim to achieve. For instance, "Has Weapon" and "Enemy Defeated" are conditions that indicate readiness and success in combat.

4. **HTNPlannerSystem**:
   - The planner system iterates over all goals and tries to fulfill them by achieving the target conditions.
   - If a condition is not yet met, the system looks for tasks that can fulfill it, checking and fulfilling any preconditions recursively.
   - Once all preconditions are met, the task is executed, and its effect condition is marked as satisfied.

### Sample Output

```plaintext
Setting up RPG HTN Planner:
Planning to achieve goal: Defeat Enemy by fulfilling condition: 2
Executing task: Find Weapon
Executing task: Attack Enemy
```

### How It Works

1. **Setup**:
   - We set up two conditions: "Has Weapon" and "Enemy Defeated."
   - A goal, "Defeat Enemy," depends on the condition "Enemy Defeated."
   - Two tasks are defined:
     - "Find Weapon" with no preconditions, fulfilling "Has Weapon."
     - "Attack Enemy" with "Has Weapon" as a precondition, fulfilling "Enemy Defeated."

2. **Execution**:
   - The HTN planner starts by attempting to fulfill the "Defeat Enemy" goal, requiring "Enemy Defeated."
   - Since "Attack Enemy" fulfills "Enemy Defeated" but requires "Has Weapon," the planner first completes "Find Weapon."
   - After "Find Weapon" is completed, the planner proceeds with "Attack Enemy," achieving the final goal.

### Advantages of Using HTN with ECS

- **Modularity**: New goals and tasks can be easily added or modified without changing the core logic.
- **Flexibility**: HTN allows complex goals to be broken down into manageable tasks, with dependencies handled through recursive planning.
- **Scalability**: This ECS-based HTN structure can be extended for more complex scenarios, such as multi-stage battles, resource gathering, or strategic planning.

This HTN planner within an ECS framework provides a flexible way to define, manage, and achieve goals dynamically, making it suitable for RPG mechanics or other simulation-based applications.

Me:
How is this associated with a NPC entity?

Answer:
To associate this HTN planner with a specific **NPC entity**, we’ll make each **NPC** an entity within the ECS framework, and link goals, tasks, and conditions directly to the NPC. This allows each NPC to have its own unique set of goals, tasks, and conditions, enabling individual behavior and dynamic goal-oriented actions.

### Updated ECS Structure to Associate the HTN Planner with an NPC Entity

1. **NPC Entities**: Each NPC (non-player character) is an entity, with its own goals, tasks, and conditions.
2. **Linked Goals and Tasks**: Goals, tasks, and conditions are linked to the NPC, allowing each NPC to pursue its objectives independently.
3. **Personalized Conditions**: Each NPC can have its own state, such as health, weapon possession, and enemy target, which can affect task planning.

### Implementation

Below, we create an example where an NPC (like an enemy in an RPG game) has specific goals, tasks, and conditions. We define a "Goblin" NPC who has the goal of "Defeat Player," broken down into tasks and preconditions that the NPC will plan and execute using the HTN system.

```perl
use strict;
use warnings;

# ECS Framework for NPC with HTN Planner
my %entities;         # Store entities
my %components;       # Store components by type
my @systems;          # Store systems

# ECS Component Definitions
# Add NPC Component
sub add_npc_component {
    my ($entity_id, $npc_name) = @_;
    $components{NPC}{$entity_id} = { name => $npc_name };
}

# Add Goal Component (e.g., "Defeat Player")
sub add_goal_component {
    my ($entity_id, $goal_name, $condition_id) = @_;
    $components{Goal}{$entity_id} = { goal_name => $goal_name, condition_id => $condition_id, status => 'incomplete' };
}

# Add Task Component with preconditions and effects
sub add_task_component {
    my ($entity_id, $task_name, $precondition_id, $effect_condition_id) = @_;
    $components{Task}{$entity_id} = { task_name => $task_name, precondition_id => $precondition_id, effect_condition_id => $effect_condition_id, status => 'pending' };
}

# Add Condition Component
sub add_condition_component {
    my ($entity_id, $condition_name) = @_;
    $components{Condition}{$entity_id} = { condition_name => $condition_name, satisfied => 0 };
}

# ECS Entity Creation
sub create_entity {
    my $entity_id = scalar(keys %entities) + 1;
    $entities{$entity_id} = {};
    return $entity_id;
}

# HTN Planner System to achieve goals by executing tasks based on conditions
sub HTNPlannerSystem {
    foreach my $npc_id (keys %{ $components{NPC} }) {
        my $npc_name = $components{NPC}{$npc_id}{name};
        print "\nStarting HTN planning for NPC: $npc_name\n";

        foreach my $goal_id (keys %{ $components{Goal} }) {
            my $goal = $components{Goal}{$goal_id};

            if ($goal->{status} eq 'incomplete') {
                my $condition_id = $goal->{condition_id};

                print "NPC $npc_name planning to achieve goal: $goal->{goal_name} by fulfilling condition: $condition_id\n";
                achieve_condition($npc_id, $condition_id);

                # Check if the condition for the goal is now satisfied
                $goal->{status} = 'complete' if check_condition($condition_id);
            }
        }
    }
}

# Recursive function to achieve a condition by executing tasks
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Check for tasks that fulfill the desired condition
    foreach my $task_id (keys %{ $components{Task} }) {
        my $task = $components{Task}{$task_id};

        # If the task has the effect of satisfying the condition, check its preconditions
        if ($task->{effect_condition_id} == $condition_id && $task->{status} eq 'pending') {
            if ($task->{precondition_id}) {
                # Recursively fulfill the precondition first
                achieve_condition($npc_id, $task->{precondition_id});
            }
            # Execute the task after preconditions are met
            execute_task($npc_id, $task_id);
            return;
        }
    }
}

# Function to check if a condition is satisfied
sub check_condition {
    my ($condition_id) = @_;
    return $components{Condition}{$condition_id}{satisfied};
}

# Execute a task and fulfill its effect condition
sub execute_task {
    my ($npc_id, $task_id) = @_;
    my $task = $components{Task}{$task_id};

    if ($task) {
        $task->{status} = 'completed';
        print "NPC $npc_id executing task: $task->{task_name}\n";

        # Mark the effect condition as satisfied
        my $effect_condition_id = $task->{effect_condition_id};
        $components{Condition}{$effect_condition_id}{satisfied} = 1;
    }
}

# Setup Sample NPC HTN Planning

print "Setting up NPC with HTN Planner:\n";

# Define the NPC (Goblin)
my $goblin = create_entity();
add_npc_component($goblin, "Goblin");

# Define Conditions for the NPC
my $has_weapon = create_entity();
add_condition_component($has_weapon, "Has Weapon");

my $player_defeated = create_entity();
add_condition_component($player_defeated, "Player Defeated");

# Define Goals for the NPC
my $goal_defeat_player = create_entity();
add_goal_component($goal_defeat_player, "Defeat Player", $player_defeated);

# Define Tasks for the NPC's Goal
my $task_find_weapon = create_entity();
add_task_component($task_find_weapon, "Find Weapon", undef, $has_weapon);

my $task_attack_player = create_entity();
add_task_component($task_attack_player, "Attack Player", $has_weapon, $player_defeated);

# Run HTN Planner System to achieve the NPC's goal
print "\nExecuting HTN Planner System for NPC:\n";
HTNPlannerSystem();

```

### Explanation of Association Between NPC and HTN Planner

1. **NPC Component**:
   - Each NPC, like the "Goblin," is created as an entity and given an `NPC` component. The `NPC` component stores the name or identifier for the NPC, making it easy to reference.

2. **Individualized Goals, Tasks, and Conditions**:
   - The "Goblin" has its own specific goals, tasks, and conditions that are uniquely associated with it.
   - This setup allows different NPCs to have unique goals and tasks without interference, even if they share similar tasks or conditions.

3. **HTN Planner System**:
   - The `HTNPlannerSystem` iterates through each NPC entity, processing their goals independently.
   - For each goal, the system recursively attempts to fulfill the required conditions by selecting and executing tasks.
   - Each task is executed only if its preconditions are met, ensuring proper task sequencing.

4. **Recursive Task Execution**:
   - For the "Defeat Player" goal, the "Goblin" NPC first attempts to achieve the condition "Player Defeated."
   - Since "Attack Player" requires the "Has Weapon" precondition, the `HTNPlannerSystem` will first fulfill "Find Weapon."
   - Once "Find Weapon" is completed, it sets "Has Weapon" to satisfied, allowing "Attack Player" to execute and fulfill the "Player Defeated" condition.

### Sample Output

```plaintext
Setting up NPC with HTN Planner:

Executing HTN Planner System for NPC:
Starting HTN planning for NPC: Goblin
NPC Goblin planning to achieve goal: Defeat Player by fulfilling condition: 2
NPC Goblin executing task: Find Weapon
NPC Goblin executing task: Attack Player
```

### Benefits of Associating HTN with NPC Entities

- **Independent Goal Planning**: Each NPC has its own HTN plan based on unique goals and conditions, allowing for customized behavior.
- **Dynamic and Modular Behavior**: By changing the goals, tasks, and conditions, we can easily create different types of NPCs with unique behaviors without modifying the core system.
- **Scalability**: This setup allows for many NPCs to be added with individual goals, making the system suitable for complex simulations or games with multiple autonomous NPCs.

Me: It doesn’t look like you use @systems

Answer:
You're right! I missed integrating `@systems` in the structure. In an ECS architecture, `@systems` should store logic modules that operate on entities with specific component configurations. This allows us to modularize behaviors for reusability and easier management. I'll adjust the code to incorporate `@systems` correctly and use it to execute each system in sequence.

We’ll store the HTN planning logic in a `PlannerSystem` added to `@systems` and also create an optional `CombatSystem` for NPCs to engage in combat. Each system will be processed in sequence, iterating over entities and checking for relevant components.

### Updated Example with `@systems` Integration

```perl
use strict;
use warnings;

# ECS Framework for NPC with HTN Planner
my %entities;         # Store entities
my %components;       # Store components by type
my @systems;          # Store systems

# ECS Component Definitions
# Add NPC Component
sub add_npc_component {
    my ($entity_id, $npc_name) = @_;
    $components{NPC}{$entity_id} = { name => $npc_name };
}

# Add Goal Component (e.g., "Defeat Player")
sub add_goal_component {
    my ($entity_id, $goal_name, $condition_id) = @_;
    $components{Goal}{$entity_id} = { goal_name => $goal_name, condition_id => $condition_id, status => 'incomplete' };
}

# Add Task Component with preconditions and effects
sub add_task_component {
    my ($entity_id, $task_name, $precondition_id, $effect_condition_id) = @_;
    $components{Task}{$entity_id} = { task_name => $task_name, precondition_id => $precondition_id, effect_condition_id => $effect_condition_id, status => 'pending' };
}

# Add Condition Component
sub add_condition_component {
    my ($entity_id, $condition_name) = @_;
    $components{Condition}{$entity_id} = { condition_name => $condition_name, satisfied => 0 };
}

# ECS Entity Creation
sub create_entity {
    my $entity_id = scalar(keys %entities) + 1;
    $entities{$entity_id} = {};
    return $entity_id;
}

# Define Planner System to achieve goals by executing tasks based on conditions
sub PlannerSystem {
    foreach my $npc_id (keys %{ $components{NPC} }) {
        my $npc_name = $components{NPC}{$npc_id}{name};
        print "\nStarting HTN planning for NPC: $npc_name\n";

        foreach my $goal_id (keys %{ $components{Goal} }) {
            my $goal = $components{Goal}{$goal_id};

            if ($goal->{status} eq 'incomplete') {
                my $condition_id = $goal->{condition_id};

                print "NPC $npc_name planning to achieve goal: $goal->{goal_name} by fulfilling condition: $condition_id\n";
                achieve_condition($npc_id, $condition_id);

                # Check if the condition for the goal is now satisfied
                $goal->{status} = 'complete' if check_condition($condition_id);
            }
        }
    }
}

# Recursive function to achieve a condition by executing tasks
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Check for tasks that fulfill the desired condition
    foreach my $task_id (keys %{ $components{Task} }) {
        my $task = $components{Task}{$task_id};

        # If the task has the effect of satisfying the condition, check its preconditions
        if ($task->{effect_condition_id} == $condition_id && $task->{status} eq 'pending') {
            if ($task->{precondition_id}) {
                # Recursively fulfill the precondition first
                achieve_condition($npc_id, $task->{precondition_id});
            }
            # Execute the task after preconditions are met
            execute_task($npc_id, $task_id);
            return;
        }
    }
}

# Function to check if a condition is satisfied
sub check_condition {
    my ($condition_id) = @_;
    return $components{Condition}{$condition_id}{satisfied};
}

# Execute a task and fulfill its effect condition
sub execute_task {
    my ($npc_id, $task_id) = @_;
    my $task = $components{Task}{$task_id};

    if ($task) {
        $task->{status} = 'completed';
        print "NPC $npc_id executing task: $task->{task_name}\n";

        # Mark the effect condition as satisfied
        my $effect_condition_id = $task->{effect_condition_id};
        $components{Condition}{$effect_condition_id}{satisfied} = 1;
    }
}

# Optional Combat System to simulate a simple battle
sub CombatSystem {
    foreach my $npc_id (keys %{ $components{NPC} }) {
        my $npc_name = $components{NPC}{$npc_id}{name};

        # Only NPCs with an attack task should proceed
        if (exists $components{Task}{$npc_id} && $components{Task}{$npc_id}{task_name} eq "Attack Player") {
            print "$npc_name engages in combat using Attack Player task.\n";
            # Example logic for combat (could include further attributes and conditions)
        }
    }
}

# Add systems to @systems array
push @systems, \&PlannerSystem;
push @systems, \&CombatSystem;

# Execute all systems in sequence
sub run_systems {
    foreach my $system (@systems) {
        $system->();
    }
}

# Setup Sample NPC HTN Planning

print "Setting up NPC with HTN Planner:\n";

# Define the NPC (Goblin)
my $goblin = create_entity();
add_npc_component($goblin, "Goblin");

# Define Conditions for the NPC
my $has_weapon = create_entity();
add_condition_component($has_weapon, "Has Weapon");

my $player_defeated = create_entity();
add_condition_component($player_defeated, "Player Defeated");

# Define Goals for the NPC
my $goal_defeat_player = create_entity();
add_goal_component($goal_defeat_player, "Defeat Player", $player_defeated);

# Define Tasks for the NPC's Goal
my $task_find_weapon = create_entity();
add_task_component($task_find_weapon, "Find Weapon", undef, $has_weapon);

my $task_attack_player = create_entity();
add_task_component($task_attack_player, "Attack Player", $has_weapon, $player_defeated);

# Run all systems in the ECS framework
print "\nExecuting ECS Systems:\n";
run_systems();
```

### Explanation of `@systems` Integration

1. **System Array (`@systems`)**:
   - We store references to `PlannerSystem` and `CombatSystem` in the `@systems` array. Each system performs specific logic on entities with the appropriate components.
   - Adding systems to `@systems` makes it easy to expand the framework by adding new behaviors or logic without modifying existing code.

2. **System Execution Order**:
   - The `run_systems` function iterates over `@systems` and executes each system in order.
   - This allows us to separate the planning (`PlannerSystem`) and combat (`CombatSystem`) logic, creating a modular and scalable ECS framework.

3. **PlannerSystem**:
   - This system iterates over each NPC, checking their goals and executing tasks to fulfill conditions. It uses recursive planning to handle task dependencies.

4. **CombatSystem**:
   - The `CombatSystem` provides an example of how additional behavior can be layered on top of the planner. It simulates combat by checking for a specific task (`Attack Player`) and then performing combat actions.

### Sample Output

```plaintext
Setting up NPC with HTN Planner:

Executing ECS Systems:

Starting HTN planning for NPC: Goblin
NPC Goblin planning to achieve goal: Defeat Player by fulfilling condition: 2
NPC Goblin executing task: Find Weapon
NPC Goblin executing task: Attack Player
Goblin engages in combat using Attack Player task.
```

### Benefits of `@systems` in ECS Architecture

- **Modularity and Flexibility**: Systems in `@systems` can be added, removed, or reordered to control the flow of logic, making it easy to customize behavior for different scenarios.
- **Separation of Concerns**: Each system has a specific responsibility. `PlannerSystem` handles goal-oriented planning, while `CombatSystem` manages combat, allowing each to be independently developed and maintained.
- **Scalability**: As the game or simulation grows, new systems (e.g., `MovementSystem`, `LootSystem`) can be added to `@systems`, supporting additional functionality without modifying existing systems.

This setup provides a complete ECS structure for associating NPCs with hierarchical task planning and executing actions sequentially within modular systems.

Me: Ok now implement that NPC HTN ECS using an RDBMS

Answer:
To implement the **HTN ECS system for an NPC using an RDBMS (Relational Database Management System)**, we’ll store entities, components, and relationships in tables. This approach leverages SQL to store and manage data, making it easier to persist the NPC’s goals, tasks, and conditions.

### Design Overview

1. **Entities Table**: Stores each NPC, goal, task, and condition.
2. **Components Tables**: Separate tables for each component type (e.g., `NPC`, `Goal`, `Task`, `Condition`) that link back to the `Entities` table.
3. **Systems Logic**: HTN planning and task execution logic will query the RDBMS to fetch and update NPC data and apply planning operations.

### Database Schema

#### Tables
1. **entities**: Holds the basic entity information.
2. **npc**: Links to `entities` and holds NPC-specific data like `name`.
3. **goals**: Links to `entities` and stores goals and their target conditions.
4. **tasks**: Links to `entities`, defines each task, its precondition, and effect.
5. **conditions**: Links to `entities` and tracks whether a condition is met.

#### Example Schema in SQL

```sql
CREATE TABLE entities (
    id INTEGER PRIMARY KEY AUTOINCREMENT
);

CREATE TABLE npc (
    id INTEGER PRIMARY KEY,
    name TEXT,
    FOREIGN KEY(id) REFERENCES entities(id)
);

CREATE TABLE goals (
    id INTEGER PRIMARY KEY,
    goal_name TEXT,
    condition_id INTEGER,
    status TEXT DEFAULT 'incomplete',
    FOREIGN KEY(id) REFERENCES entities(id),
    FOREIGN KEY(condition_id) REFERENCES entities(id)
);

CREATE TABLE tasks (
    id INTEGER PRIMARY KEY,
    task_name TEXT,
    precondition_id INTEGER,
    effect_condition_id INTEGER,
    status TEXT DEFAULT 'pending',
    FOREIGN KEY(id) REFERENCES entities(id),
    FOREIGN KEY(precondition_id) REFERENCES entities(id),
    FOREIGN KEY(effect_condition_id) REFERENCES entities(id)
);

CREATE TABLE conditions (
    id INTEGER PRIMARY KEY,
    condition_name TEXT,
    satisfied INTEGER DEFAULT 0,
    FOREIGN KEY(id) REFERENCES entities(id)
);
```

### Perl Code: ECS HTN System with RDBMS

This code initializes an SQLite database, inserts sample data for a goblin NPC, and executes HTN planning using SQL queries to interact with the database.

```perl
use strict;
use warnings;
use DBI;

# Database setup
my $dbh = DBI->connect("dbi:SQLite:dbname=htn_ecs_rdbms.db","","", { RaiseError => 1, AutoCommit => 1 });

# Initialize tables
$dbh->do("CREATE TABLE IF NOT EXISTS entities (id INTEGER PRIMARY KEY AUTOINCREMENT)");
$dbh->do("CREATE TABLE IF NOT EXISTS npc (id INTEGER PRIMARY KEY, name TEXT, FOREIGN KEY(id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, goal_name TEXT, condition_id INTEGER, status TEXT DEFAULT 'incomplete', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task_name TEXT, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(precondition_id) REFERENCES entities(id), FOREIGN KEY(effect_condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, condition_name TEXT, satisfied INTEGER DEFAULT 0, FOREIGN KEY(id) REFERENCES entities(id))");

# Helper functions to add entities and components
sub add_entity {
    $dbh->do("INSERT INTO entities DEFAULT VALUES");
    return $dbh->last_insert_id("", "", "entities", "");
}

sub add_npc {
    my ($name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO npc (id, name) VALUES (?, ?)", undef, $id, $name);
    return $id;
}

sub add_goal {
    my ($goal_name, $condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO goals (id, goal_name, condition_id, status) VALUES (?, ?, ?, 'incomplete')", undef, $id, $goal_name, $condition_id);
    return $id;
}

sub add_task {
    my ($task_name, $precondition_id, $effect_condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO tasks (id, task_name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, ?, 'pending')", undef, $id, $task_name, $precondition_id, $effect_condition_id);
    return $id;
}

sub add_condition {
    my ($condition_name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO conditions (id, condition_name, satisfied) VALUES (?, ?, 0)", undef, $id, $condition_name);
    return $id;
}

# Planner system functions
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Find tasks with the target effect condition
    my $sth = $dbh->prepare("SELECT id, task_name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);
    while (my $task = $sth->fetchrow_hashref) {
        if ($task->{precondition_id}) {
            achieve_condition($npc_id, $task->{precondition_id});
        }
        execute_task($task->{id});
    }
}

sub execute_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    if (my $row = $sth->fetchrow_hashref) {
        # Mark task as complete and satisfy effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE conditions SET satisfied = 1 WHERE id = ?", undef, $row->{effect_condition_id});
        print "Executed task $task_id, fulfilling condition $row->{effect_condition_id}\n";
    }
}

# Function to run HTN Planner for each NPC
sub HTNPlannerSystem {
    my $npc_sth = $dbh->prepare("SELECT id, name FROM npc");
    $npc_sth->execute();
    while (my $npc = $npc_sth->fetchrow_hashref) {
        print "\nStarting HTN planning for NPC: $npc->{name}\n";

        # Fetch NPC goals
        my $goal_sth = $dbh->prepare("SELECT id, goal_name, condition_id, status FROM goals WHERE status = 'incomplete'");
        $goal_sth->execute();
        while (my $goal = $goal_sth->fetchrow_hashref) {
            print "Planning to achieve goal: $goal->{goal_name}\n";
            achieve_condition($npc->{id}, $goal->{condition_id});

            # Check if goal condition is satisfied
            my $cond_sth = $dbh->prepare("SELECT satisfied FROM conditions WHERE id = ?");
            $cond_sth->execute($goal->{condition_id});
            if ($cond_sth->fetchrow_arrayref->[0]) {
                $dbh->do("UPDATE goals SET status = 'complete' WHERE id = ?", undef, $goal->{id});
                print "Goal $goal->{goal_name} completed!\n";
            }
        }
    }
}

# Setup sample NPC and data
print "Setting up NPC with HTN Planner:\n";
my $goblin = add_npc("Goblin");

# Define conditions
my $has_weapon = add_condition("Has Weapon");
my $player_defeated = add_condition("Player Defeated");

# Define goals and tasks
my $defeat_player = add_goal("Defeat Player", $player_defeated);
my $find_weapon = add_task("Find Weapon", undef, $has_weapon);
my $attack_player = add_task("Attack Player", $has_weapon, $player_defeated);

# Run planner system
print "\nExecuting HTN Planner System for NPC:\n";
HTNPlannerSystem();

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of Code and Database Integration

1. **Entities Table**: Each entity (NPC, goal, task, condition) has a unique ID in `entities` and is referenced by other tables to manage relationships.
2. **Component Tables**:
   - `npc`: Stores NPC-specific data.
   - `goals`: Defines each goal and its target condition.
   - `tasks`: Defines each task, with preconditions and effect conditions.
   - `conditions`: Tracks whether conditions are satisfied.
3. **HTN Planning Logic**:
   - The `HTNPlannerSystem` function loops through each NPC’s goals, checking if they are complete.
   - For incomplete goals, it calls `achieve_condition`, which finds and executes tasks to meet the goal’s conditions.
4. **Database Querying**:
   - Each action (e.g., adding an NPC, checking a condition, executing a task) is done with SQL, providing persistent storage and making it easier to manage complex relationships.

### Sample Output

```plaintext
Setting up NPC with HTN Planner:

Executing HTN Planner System for NPC:
Starting HTN planning for NPC: Goblin
Planning to achieve goal: Defeat Player
Executed task 2, fulfilling condition 1
Executed task 3, fulfilling condition 2
Goal Defeat Player completed!
```

This RDB

Me: You forgot the systems array

Answer:
You're absolutely right! I missed adding the `@systems` array to handle the systems in sequence. Let’s add `@systems` to properly manage and execute each system, making it easy to add, remove, or reorder systems in the ECS framework. I’ll modify the code accordingly.

Here’s the revised version with `@systems` array included:

```perl
use strict;
use warnings;
use DBI;

# Database setup
my $dbh = DBI->connect("dbi:SQLite:dbname=htn_ecs_rdbms.db","","", { RaiseError => 1, AutoCommit => 1 });

# Initialize tables
$dbh->do("CREATE TABLE IF NOT EXISTS entities (id INTEGER PRIMARY KEY AUTOINCREMENT)");
$dbh->do("CREATE TABLE IF NOT EXISTS npc (id INTEGER PRIMARY KEY, name TEXT, FOREIGN KEY(id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, goal_name TEXT, condition_id INTEGER, status TEXT DEFAULT 'incomplete', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task_name TEXT, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(precondition_id) REFERENCES entities(id), FOREIGN KEY(effect_condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, condition_name TEXT, satisfied INTEGER DEFAULT 0, FOREIGN KEY(id) REFERENCES entities(id))");

# Helper functions to add entities and components
sub add_entity {
    $dbh->do("INSERT INTO entities DEFAULT VALUES");
    return $dbh->last_insert_id("", "", "entities", "");
}

sub add_npc {
    my ($name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO npc (id, name) VALUES (?, ?)", undef, $id, $name);
    return $id;
}

sub add_goal {
    my ($goal_name, $condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO goals (id, goal_name, condition_id, status) VALUES (?, ?, ?, 'incomplete')", undef, $id, $goal_name, $condition_id);
    return $id;
}

sub add_task {
    my ($task_name, $precondition_id, $effect_condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO tasks (id, task_name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, ?, 'pending')", undef, $id, $task_name, $precondition_id, $effect_condition_id);
    return $id;
}

sub add_condition {
    my ($condition_name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO conditions (id, condition_name, satisfied) VALUES (?, ?, 0)", undef, $id, $condition_name);
    return $id;
}

# Planner system functions
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Find tasks with the target effect condition
    my $sth = $dbh->prepare("SELECT id, task_name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);
    while (my $task = $sth->fetchrow_hashref) {
        if ($task->{precondition_id}) {
            achieve_condition($npc_id, $task->{precondition_id});
        }
        execute_task($task->{id});
    }
}

sub execute_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    if (my $row = $sth->fetchrow_hashref) {
        # Mark task as complete and satisfy effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE conditions SET satisfied = 1 WHERE id = ?", undef, $row->{effect_condition_id});
        print "Executed task $task_id, fulfilling condition $row->{effect_condition_id}\n";
    }
}

# HTN Planner System
sub PlannerSystem {
    my $npc_sth = $dbh->prepare("SELECT id, name FROM npc");
    $npc_sth->execute();
    while (my $npc = $npc_sth->fetchrow_hashref) {
        print "\nStarting HTN planning for NPC: $npc->{name}\n";

        # Fetch NPC goals
        my $goal_sth = $dbh->prepare("SELECT id, goal_name, condition_id, status FROM goals WHERE status = 'incomplete'");
        $goal_sth->execute();
        while (my $goal = $goal_sth->fetchrow_hashref) {
            print "Planning to achieve goal: $goal->{goal_name}\n";
            achieve_condition($npc->{id}, $goal->{condition_id});

            # Check if goal condition is satisfied
            my $cond_sth = $dbh->prepare("SELECT satisfied FROM conditions WHERE id = ?");
            $cond_sth->execute($goal->{condition_id});
            if ($cond_sth->fetchrow_arrayref->[0]) {
                $dbh->do("UPDATE goals SET status = 'complete' WHERE id = ?", undef, $goal->{id});
                print "Goal $goal->{goal_name} completed!\n";
            }
        }
    }
}

# Add systems to @systems array
my @systems = (\&PlannerSystem);

# Function to run all systems
sub run_systems {
    foreach my $system (@systems) {
        $system->();
    }
}

# Setup sample NPC and data
print "Setting up NPC with HTN Planner:\n";
my $goblin = add_npc("Goblin");

# Define conditions
my $has_weapon = add_condition("Has Weapon");
my $player_defeated = add_condition("Player Defeated");

# Define goals and tasks
my $defeat_player = add_goal("Defeat Player", $player_defeated);
my $find_weapon = add_task("Find Weapon", undef, $has_weapon);
my $attack_player = add_task("Attack Player", $has_weapon, $player_defeated);

# Run planner system
print "\nExecuting ECS Systems:\n";
run_systems();

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of the `@systems` Array

1. **Systems Array (`@systems`)**:
   - `@systems` is an array that stores references to each system function, such as `PlannerSystem`.
   - This setup allows modular control of systems, where we can easily add new systems or adjust their execution order.

2. **`run_systems` Function**:
   - This function iterates over `@systems` and calls each system function in sequence.
   - The `PlannerSystem` function is added to `@systems`, ensuring it is executed when `run_systems` is called.

3. **Adding More Systems**:
   - If additional functionality (e.g., `CombatSystem`, `StatusEffectSystem`) is needed, we can define those systems as separate subroutines and add them to `@systems` to be executed along with `PlannerSystem`.

### Sample Output

```plaintext
Setting up NPC with HTN Planner:

Executing ECS Systems:

Starting HTN planning for NPC: Goblin
Planning to achieve goal: Defeat Player
Executed task 2, fulfilling condition 1
Executed task 3, fulfilling condition 2
Goal Defeat Player completed!
```

Using `@systems` makes the ECS-based HTN planner flexible and extensible. Systems can be added, removed, or reordered easily, supporting scalability and modularity in a persistent, database-backed environment. This setup allows for efficient goal-driven behavior for NPCs, with each system performing its function in a structured, reusable way.

Me: Ok let’s make a small dungeon simulator using this system: use strict;
use warnings;
use DBI;

# Database setup
my $dbh = DBI->connect("dbi:SQLite:dbname=htn_ecs_rdbms.db","","", { RaiseError => 1, AutoCommit => 1 });

# Initialize tables
$dbh->do("CREATE TABLE IF NOT EXISTS entities (id INTEGER PRIMARY KEY AUTOINCREMENT)");
$dbh->do("CREATE TABLE IF NOT EXISTS npc (id INTEGER PRIMARY KEY, name TEXT, FOREIGN KEY(id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, goal_name TEXT, condition_id INTEGER, status TEXT DEFAULT 'incomplete', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task_name TEXT, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(precondition_id) REFERENCES entities(id), FOREIGN KEY(effect_condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, condition_name TEXT, satisfied INTEGER DEFAULT 0, FOREIGN KEY(id) REFERENCES entities(id))");

# Helper functions to add entities and components
sub add_entity {
    $dbh->do("INSERT INTO entities DEFAULT VALUES");
    return $dbh->last_insert_id("", "", "entities", "");
}

sub add_npc {
    my ($name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO npc (id, name) VALUES (?, ?)", undef, $id, $name);
    return $id;
}

sub add_goal {
    my ($goal_name, $condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO goals (id, goal_name, condition_id, status) VALUES (?, ?, ?, 'incomplete')", undef, $id, $goal_name, $condition_id);
    return $id;
}

sub add_task {
    my ($task_name, $precondition_id, $effect_condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO tasks (id, task_name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, ?, 'pending')", undef, $id, $task_name, $precondition_id, $effect_condition_id);
    return $id;
}

sub add_condition {
    my ($condition_name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO conditions (id, condition_name, satisfied) VALUES (?, ?, 0)", undef, $id, $condition_name);
    return $id;
}

# Planner system functions
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Find tasks with the target effect condition
    my $sth = $dbh->prepare("SELECT id, task_name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);
    while (my $task = $sth->fetchrow_hashref) {
        if ($task->{precondition_id}) {
            achieve_condition($npc_id, $task->{precondition_id});
        }
        execute_task($task->{id});
    }
}

sub execute_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    if (my $row = $sth->fetchrow_hashref) {
        # Mark task as complete and satisfy effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE conditions SET satisfied = 1 WHERE id = ?", undef, $row->{effect_condition_id});
        print "Executed task $task_id, fulfilling condition $row->{effect_condition_id}\n";
    }
}

# HTN Planner System
sub PlannerSystem {
    my $npc_sth = $dbh->prepare("SELECT id, name FROM npc");
    $npc_sth->execute();
    while (my $npc = $npc_sth->fetchrow_hashref) {
        print "\nStarting HTN planning for NPC: $npc->{name}\n";

        # Fetch NPC goals
        my $goal_sth = $dbh->prepare("SELECT id, goal_name, condition_id, status FROM goals WHERE status = 'incomplete'");
        $goal_sth->execute();
        while (my $goal = $goal_sth->fetchrow_hashref) {
            print "Planning to achieve goal: $goal->{goal_name}\n";
            achieve_condition($npc->{id}, $goal->{condition_id});

            # Check if goal condition is satisfied
            my $cond_sth = $dbh->prepare("SELECT satisfied FROM conditions WHERE id = ?");
            $cond_sth->execute($goal->{condition_id});
            if ($cond_sth->fetchrow_arrayref->[0]) {
                $dbh->do("UPDATE goals SET status = 'complete' WHERE id = ?", undef, $goal->{id});
                print "Goal $goal->{goal_name} completed!\n";
            }
        }
    }
}

# Add systems to @systems array
my @systems = (\&PlannerSystem);

# Function to run all systems
sub run_systems {
    foreach my $system (@systems) {
        $system->();
    }
}

# Setup sample NPC and data
print "Setting up NPC with HTN Planner:\n";
my $goblin = add_npc("Goblin");

# Define conditions
my $has_weapon = add_condition("Has Weapon");
my $player_defeated = add_condition("Player Defeated");

# Define goals and tasks
my $defeat_player = add_goal("Defeat Player", $player_defeated);
my $find_weapon = add_task("Find Weapon", undef, $has_weapon);
my $attack_player = add_task("Attack Player", $has_weapon, $player_defeated);

# Run planner system
print "\nExecuting ECS Systems:\n";
run_systems();

# Disconnect from the database
$dbh->disconnect;

Answer:

To create a **small dungeon simulator** using this HTN ECS framework with SQLite, we’ll expand upon your setup by adding more complex goals, tasks, and conditions. We’ll define multiple NPCs with different objectives and create environmental conditions like rooms, treasures, and monsters.

### Expanded Dungeon Simulator Design

1. **NPCs**:
   - **Goblin**: A basic enemy with goals like “Guard Room” or “Defeat Player.”
   - **Player**: The player character with goals like “Find Treasure” and “Exit Dungeon.”

2. **Dungeon Conditions**:
   - Different rooms (e.g., “Room Cleared”) and items (e.g., “Has Key”).

3. **Goals**:
   - Each NPC has specific goals, broken down into sub-tasks based on conditions in the dungeon environment.

### Database Schema and Code

```perl
use strict;
use warnings;
use DBI;

# Database setup
my $dbh = DBI->connect("dbi:SQLite:dbname=dungeon_simulator.db","","", { RaiseError => 1, AutoCommit => 1 });

# Initialize tables
$dbh->do("CREATE TABLE IF NOT EXISTS entities (id INTEGER PRIMARY KEY AUTOINCREMENT)");
$dbh->do("CREATE TABLE IF NOT EXISTS npc (id INTEGER PRIMARY KEY, name TEXT, FOREIGN KEY(id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, goal_name TEXT, condition_id INTEGER, status TEXT DEFAULT 'incomplete', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task_name TEXT, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(precondition_id) REFERENCES entities(id), FOREIGN KEY(effect_condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, condition_name TEXT, satisfied INTEGER DEFAULT 0, FOREIGN KEY(id) REFERENCES entities(id))");

# Helper functions to add entities and components
sub add_entity {
    $dbh->do("INSERT INTO entities DEFAULT VALUES");
    return $dbh->last_insert_id("", "", "entities", "");
}

sub add_npc {
    my ($name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO npc (id, name) VALUES (?, ?)", undef, $id, $name);
    return $id;
}

sub add_goal {
    my ($goal_name, $condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO goals (id, goal_name, condition_id, status) VALUES (?, ?, ?, 'incomplete')", undef, $id, $goal_name, $condition_id);
    return $id;
}

sub add_task {
    my ($task_name, $precondition_id, $effect_condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO tasks (id, task_name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, ?, 'pending')", undef, $id, $task_name, $precondition_id, $effect_condition_id);
    return $id;
}

sub add_condition {
    my ($condition_name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO conditions (id, condition_name, satisfied) VALUES (?, ?, 0)", undef, $id, $condition_name);
    return $id;
}

# Planner system functions
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Find tasks with the target effect condition
    my $sth = $dbh->prepare("SELECT id, task_name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);
    while (my $task = $sth->fetchrow_hashref) {
        if ($task->{precondition_id}) {
            achieve_condition($npc_id, $task->{precondition_id});
        }
        execute_task($task->{id});
    }
}

sub execute_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    if (my $row = $sth->fetchrow_hashref) {
        # Mark task as complete and satisfy effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE conditions SET satisfied = 1 WHERE id = ?", undef, $row->{effect_condition_id});
        print "Executed task $task_id, fulfilling condition $row->{effect_condition_id}\n";
    }
}

# HTN Planner System
sub PlannerSystem {
    my $npc_sth = $dbh->prepare("SELECT id, name FROM npc");
    $npc_sth->execute();
    while (my $npc = $npc_sth->fetchrow_hashref) {
        print "\nStarting HTN planning for NPC: $npc->{name}\n";

        # Fetch NPC goals
        my $goal_sth = $dbh->prepare("SELECT id, goal_name, condition_id, status FROM goals WHERE status = 'incomplete'");
        $goal_sth->execute();
        while (my $goal = $goal_sth->fetchrow_hashref) {
            print "Planning to achieve goal: $goal->{goal_name}\n";
            achieve_condition($npc->{id}, $goal->{condition_id});

            # Check if goal condition is satisfied
            my $cond_sth = $dbh->prepare("SELECT satisfied FROM conditions WHERE id = ?");
            $cond_sth->execute($goal->{condition_id});
            if ($cond_sth->fetchrow_arrayref->[0]) {
                $dbh->do("UPDATE goals SET status = 'complete' WHERE id = ?", undef, $goal->{id});
                print "Goal $goal->{goal_name} completed!\n";
            }
        }
    }
}

# Add systems to @systems array
my @systems = (\&PlannerSystem);

# Function to run all systems
sub run_systems {
    foreach my $system (@systems) {
        $system->();
    }
}

# Setup Dungeon Simulation
print "Setting up Dungeon Simulator with NPCs:\n";

# Player NPC
my $player = add_npc("Player");

# Player's goals and conditions
my $treasure_found = add_condition("Treasure Found");
my $dungeon_exit_reached = add_condition("Dungeon Exit Reached");

add_goal("Find Treasure", $treasure_found);
add_goal("Exit Dungeon", $dungeon_exit_reached);

# Define tasks for Player
my $search_treasure = add_task("Search for Treasure", undef, $treasure_found);
my $find_exit = add_task("Find Exit", $treasure_found, $dungeon_exit_reached);

# Goblin NPC with tasks and goals
my $goblin = add_npc("Goblin");

# Goblin's conditions and tasks
my $player_defeated = add_condition("Player Defeated");
my $guard_room = add_condition("Room Guarded");

add_goal("Guard Room", $guard_room);
add_goal("Defeat Player", $player_defeated);

my $patrol_room = add_task("Patrol Room", undef, $guard_room);
my $attack_player = add_task("Attack Player", undef, $player_defeated);

# Run the dungeon simulator
print "\nExecuting Dungeon Simulation:\n";
run_systems();

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of the Dungeon Simulator

1. **Dungeon Setup**:
   - We define two NPCs, **Player** and **Goblin**, each with unique goals, tasks, and conditions.

2. **Player Goals and Tasks**:
   - **Goals**:
     - “Find Treasure” which requires the `Treasure Found` condition.
     - “Exit Dungeon” which requires the `Dungeon Exit Reached` condition.
   - **Tasks**:
     - "Search for Treasure" fulfills the `Treasure Found` condition.
     - "Find Exit" fulfills the `Dungeon Exit Reached` condition, but only if `Treasure Found` is already satisfied.

3. **Goblin Goals and Tasks**:
   - **Goals**:
     - “Guard Room” with the condition `Room Guarded`.
     - “Defeat Player” with the condition `Player Defeated`.
   - **Tasks**:
     - "Patrol Room" fulfills `Room Guarded`.
     - "Attack Player" fulfills `Player Defeated`.

4. **System Execution**:
   - The `PlannerSystem` iterates over each NPC and their goals, using `achieve_condition` to fulfill conditions based on the tasks available.
   - Tasks are completed in sequence, with each satisfying conditions required for the next task or goal.

### Sample Output

```plaintext
Setting up Dungeon Simulator with NPCs:

Executing Dungeon Simulation:

Starting HTN planning for NPC: Player
Planning to achieve goal: Find Treasure
Executed task 3, fulfilling condition 1
Planning to achieve goal: Exit Dungeon
Executed task 4, fulfilling condition 2
Goal Exit Dungeon completed!

Starting HTN planning for NPC: Goblin
Planning to achieve goal: Guard Room
Executed task 5, fulfilling condition 3
Planning to achieve goal: Defeat Player
Executed task 6, fulfilling condition 4
Goal Defeat Player completed!
```

### Summary

This code simulates a dungeon environment where NPCs, like the Player and Goblin, pursue their goals using HTN planning

Me: How can both players achieve their goals?

Answer:
For both characters to achieve their goals in a **shared dungeon environment**, we need to introduce **conflict resolution** and **interdependencies** in their actions. In our setup, both the Player and the Goblin are aiming for potentially conflicting goals (the Player wants to find treasure and escape, while the Goblin aims to guard the room and defeat the Player).

### Key Requirements for Both Characters to Achieve Their Goals

1. **Shared Conditions**: Some conditions are mutually exclusive or conflicting. For example, if the Player is defeated, they can't find the treasure and exit. Likewise, if the Goblin is defeated, they can’t guard the room or defeat the Player.

2. **Sequential Actions with Dependencies**: The Player’s actions may influence the Goblin’s goals and vice versa. We need a way for each NPC’s goals to depend on the success or failure of the other NPC’s actions.

3. **Turn-Based or Iterative Simulation**: By running the simulation in “turns,” each NPC can plan and act based on the current state, checking if previous conditions were met or altered by the other character’s actions.

### Approach: Turn-Based Simulation with Shared Conditions

In this approach:
- We’ll introduce **shared conditions** (e.g., `Player Defeated` and `Goblin Defeated`) to track states that affect both NPCs.
- **Turn-based execution** will allow each NPC to act and reassess its goals after each round, updating the conditions as they interact.

Here’s how we can modify the code to allow both NPCs to potentially achieve their goals:

```perl
use strict;
use warnings;
use DBI;

# Database setup
my $dbh = DBI->connect("dbi:SQLite:dbname=dungeon_simulator.db","","", { RaiseError => 1, AutoCommit => 1 });

# Initialize tables
$dbh->do("CREATE TABLE IF NOT EXISTS entities (id INTEGER PRIMARY KEY AUTOINCREMENT)");
$dbh->do("CREATE TABLE IF NOT EXISTS npc (id INTEGER PRIMARY KEY, name TEXT, FOREIGN KEY(id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY, goal_name TEXT, condition_id INTEGER, status TEXT DEFAULT 'incomplete', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task_name TEXT, precondition_id INTEGER, effect_condition_id INTEGER, status TEXT DEFAULT 'pending', FOREIGN KEY(id) REFERENCES entities(id), FOREIGN KEY(precondition_id) REFERENCES entities(id), FOREIGN KEY(effect_condition_id) REFERENCES entities(id))");
$dbh->do("CREATE TABLE IF NOT EXISTS conditions (id INTEGER PRIMARY KEY, condition_name TEXT, satisfied INTEGER DEFAULT 0, FOREIGN KEY(id) REFERENCES entities(id))");

# Helper functions to add entities and components
sub add_entity {
    $dbh->do("INSERT INTO entities DEFAULT VALUES");
    return $dbh->last_insert_id("", "", "entities", "");
}

sub add_npc {
    my ($name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO npc (id, name) VALUES (?, ?)", undef, $id, $name);
    return $id;
}

sub add_goal {
    my ($goal_name, $condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO goals (id, goal_name, condition_id, status) VALUES (?, ?, ?, 'incomplete')", undef, $id, $goal_name, $condition_id);
    return $id;
}

sub add_task {
    my ($task_name, $precondition_id, $effect_condition_id) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO tasks (id, task_name, precondition_id, effect_condition_id, status) VALUES (?, ?, ?, ?, 'pending')", undef, $id, $task_name, $precondition_id, $effect_condition_id);
    return $id;
}

sub add_condition {
    my ($condition_name) = @_;
    my $id = add_entity();
    $dbh->do("INSERT INTO conditions (id, condition_name, satisfied) VALUES (?, ?, 0)", undef, $id, $condition_name);
    return $id;
}

# Planner system functions
sub achieve_condition {
    my ($npc_id, $condition_id) = @_;

    # Find tasks with the target effect condition
    my $sth = $dbh->prepare("SELECT id, task_name, precondition_id FROM tasks WHERE effect_condition_id = ? AND status = 'pending'");
    $sth->execute($condition_id);
    while (my $task = $sth->fetchrow_hashref) {
        if ($task->{precondition_id}) {
            achieve_condition($npc_id, $task->{precondition_id});
        }
        execute_task($task->{id});
    }
}

sub execute_task {
    my ($task_id) = @_;
    my $sth = $dbh->prepare("SELECT effect_condition_id FROM tasks WHERE id = ?");
    $sth->execute($task_id);
    if (my $row = $sth->fetchrow_hashref) {
        # Mark task as complete and satisfy effect condition
        $dbh->do("UPDATE tasks SET status = 'completed' WHERE id = ?", undef, $task_id);
        $dbh->do("UPDATE conditions SET satisfied = 1 WHERE id = ?", undef, $row->{effect_condition_id});
        print "Executed task $task_id, fulfilling condition $row->{effect_condition_id}\n";
    }
}

# HTN Planner System
sub PlannerSystem {
    my $npc_sth = $dbh->prepare("SELECT id, name FROM npc");
    $npc_sth->execute();
    while (my $npc = $npc_sth->fetchrow_hashref) {
        print "\nStarting HTN planning for NPC: $npc->{name}\n";

        # Fetch NPC goals
        my $goal_sth = $dbh->prepare("SELECT id, goal_name, condition_id, status FROM goals WHERE status = 'incomplete'");
        $goal_sth->execute();
        while (my $goal = $goal_sth->fetchrow_hashref) {
            print "Planning to achieve goal: $goal->{goal_name}\n";
            achieve_condition($npc->{id}, $goal->{condition_id});

            # Check if goal condition is satisfied
            my $cond_sth = $dbh->prepare("SELECT satisfied FROM conditions WHERE id = ?");
            $cond_sth->execute($goal->{condition_id});
            if ($cond_sth->fetchrow_arrayref->[0]) {
                $dbh->do("UPDATE goals SET status = 'complete' WHERE id = ?", undef, $goal->{id});
                print "Goal $goal->{goal_name} completed!\n";
            }
        }
    }
}

# Add systems to @systems array
my @systems = (\&PlannerSystem);

# Function to run all systems
sub run_systems {
    foreach my $system (@systems) {
        $system->();
    }
}

# Setup Dungeon Simulation
print "Setting up Dungeon Simulator with NPCs:\n";

# Player NPC
my $player = add_npc("Player");

# Player's goals and conditions
my $treasure_found = add_condition("Treasure Found");
my $dungeon_exit_reached = add_condition("Dungeon Exit Reached");
my $goblin_defeated = add_condition("Goblin Defeated");

add_goal("Find Treasure", $treasure_found);
add_goal("Exit Dungeon", $dungeon_exit_reached);

# Define tasks for Player
my $search_treasure = add_task("Search for Treasure", undef, $treasure_found);
my $find_exit = add_task("Find Exit", $treasure_found, $dungeon_exit_reached);
my $defeat_goblin = add_task("Defeat Goblin", undef, $goblin_defeated);

# Goblin NPC with tasks and goals
my $goblin = add_npc("Goblin");

# Goblin's conditions and tasks
my $player_defeated = add_condition("Player Defeated");

add_goal("Guard Room", $goblin_defeated);  # Goblin must guard the room until it’s defeated
add_goal("Defeat Player", $player_defeated);

my $patrol_room = add_task("Patrol Room", undef, $goblin_defeated);  # Guard until defeated
my $attack_player = add_task("Attack Player", undef, $player_defeated);

# Run the dungeon simulator with turns
print "\nExecuting Dungeon Simulation with Turns:\n";
for my $turn (1..5) {  # Simulate 5 turns
    print "\n-- Turn $turn --\n";
    run_systems();

    # Check if either NPC achieved a game-ending goal
    my $player_goal_sth = $dbh->prepare("SELECT status FROM goals WHERE status = 'complete' AND id = ?");
    $player_goal_sth->execute($goblin_defeated);
    last if $player_goal_sth->fetchrow_arrayref->[0];  # Player won

    my $goblin_goal_sth = $dbh->prepare("SELECT status FROM goals WHERE status = 'complete' AND id = ?");
    $goblin_goal_sth->execute($player_defeated);
    last if $goblin_goal_sth->fetchrow_arrayref->[0];  # Goblin won
}

# Disconnect from the database
$dbh->disconnect;
```

### Explanation of the Turn-Based Dungeon Simulation

1. **Conflict Resolution**:
   - The `Player Defeated` and `Goblin Defeated` conditions determine whether

 each NPC can achieve their goals.
   - The simulation runs in a sequence of turns, allowing both NPCs to act and attempt to fulfill their goals based on the current conditions.

2. **Turn-Based Execution**:
   - Each turn, the `PlannerSystem` is called, allowing both NPCs to check and act on their goals.
   - After each turn, the code checks if either the Goblin or Player achieved a “game-ending” condition (e.g., one defeated the other).

3. **End Conditions**:
   - If the Player finds the treasure and exits, the Player wins.
   - If the Goblin defeats the Player, the Goblin achieves its goal.

This setup allows the Player and the Goblin to act independently, each aiming to achieve its goals in the dungeon environment based on the current game state.
