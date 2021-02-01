#!/usr/bin/env bash
man -k . | awk '{ print $1 " " $2 }' | rofi -dmenu -p man: | awk '{ print $2 " " $1 }' | tr -d '()' | xargs st -e man
