#!/bin/bash

task=$(zenity --entry --text="Add task")
echo "- [ ]" $task >> $NOTE/ZADANIA/week.todo
dustify "Task added"
