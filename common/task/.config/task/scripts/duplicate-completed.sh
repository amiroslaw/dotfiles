#!/bin/bash
# duplicates the completed tasks with tag next and remove that tag from old tasks
completedNext=$(task uuids +next and status:completed)
task $completedNext duplicate
task $completedNext modify -rep
# task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off "$@" modify priority:$priorityLevel
