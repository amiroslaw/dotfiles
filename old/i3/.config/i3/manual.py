#!/usr/bin/env bash
man -k . | awk '{$3="-"; print $0}'  | rofi -dmenu -p man: | awk '{ print $2 " " $1 }' | tr -d '()' | xargs $TERM_LT -e man
