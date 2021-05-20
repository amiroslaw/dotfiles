#!/bin/sh
# dependency: zenity

case "$1" in
  'show')
	awk "NR==1,/Week/" $NOTE/ZADANIA/week.todo | head -n -1 | zenity --text-info
  ;;
  'add')
	task=$(zenity --entry --text="Add task")
	echo "- [ ]" $task >> $NOTE/ZADANIA/week.todo
	dustify "Task added"
  ;;
  *)
	awk "NR==1,/Week/" $NOTE/ZADANIA/week.todo | head -n -1 | zenity --text-info
  ;;
esac

# zenity --text-info --width 530 --height 530
