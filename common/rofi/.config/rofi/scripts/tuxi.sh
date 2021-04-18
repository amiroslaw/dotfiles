#!/bin/sh
# dependency: tuxi, zenity

input=$(zenity --entry --text="Ask" --width 530)
tuxi -ra $input | zenity --text-info --width 530 --height 530
# tuxi -ra $input | zenity --text-info

# rofi"
# input=$(rofi -lines 1 -width 50 -dmenu -p "Ask") 
# $TERM_LT -t "tuxi" -e less $(tuxi -a $input)
# answer=tuxi -a $input
# st -t "tuxi" -e echo $answer
