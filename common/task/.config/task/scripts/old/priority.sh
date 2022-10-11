#!/bin/bash
priorityLevel=$(echo "L|M|H" | rofi -dmenu -i -sep "|")
task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off "$@" modify priority:$priorityLevel
