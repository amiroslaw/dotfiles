#!/bin/sh
# dependency: zenity

awk "NR==1,/Week/" $NOTE/ZADANIA/week.todo | head -n -1 | zenity --text-info
# zenity --text-info --width 530 --height 530
