#!/bin/bash
# duplicates the completed tasks with tag next and remove that tag from old tasks
completed=$(task uuids +rou and status:completed)
task $completed duplicate
task $completed modify -rou
# task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off "$@" modify priority:$priorityLevel
