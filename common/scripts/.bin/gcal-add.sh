#!/bin/bash

# dependencies zenity, gcalcli

reminder=$(zenity --forms --title="reminder" \
	--text="adding 'a' in Hour will add event for all day \n
	adding sting in duration [t | tomorrow | next week | mon tue wed thu fri sat sun]" \
   --add-entry="Title" \
   --add-entry="Hour" \
   --add-entry="Minutes" \
   --add-entry="Duration" \
   --add-calendar="Date" \
	--forms-date-format=%m/%d/%Y \
   --add-entry="Description" \
   # --add-entry="Where" \
   # --add-entry="Reminder" \
	# --add-list choose --list-values="a|b"
)
echo $reminder

title=$(echo $reminder | awk 'BEGIN {FS="|" } { print $1 }')
hour=$(echo $reminder | awk 'BEGIN {FS="|" } { print $2 }')
minutes=$(echo $reminder | awk 'BEGIN {FS="|" } { print $3 }')
duration=$(echo $reminder | awk 'BEGIN {FS="|" } { print $4 }')
date=$(echo $reminder | awk 'BEGIN {FS="|" } { print $5 }')
description=$(echo $reminder | awk 'BEGIN {FS="|" } { print $6 }')
# where=$(echo $reminder | awk 'BEGIN {FS="|" } { print $6 }')

[[ -z "$title" ]] && exit 1
if [ -z "$duration" ]; then
	duration=1
fi
if [ -z "$hour" ]; then
	hour=12
fi
if [ -z "$minutes" ]; then
	minutes=00
fi
if [ "$hour" == "a" ]; then
	gcalcli --config-folder="/home/miro/.config/gcalcli" --calendar 'arek' add --title "$title" --allday --when "$date" --duration $duration --description "$description" --where " " --reminder '10m popup'
elif [ "$duration" == "t" ]; then
	gcalcli --config-folder="/home/miro/.config/gcalcli" --calendar 'arek' add --title "$title" --when "tomorrow $hour:$minutes" --duration 60 --description "$description" --where ' ' --reminder '10m popup'
elif ! [[ $duration =~ ^-?[0-9]+$ ]]; then
	gcalcli --config-folder="/home/miro/.config/gcalcli" --calendar 'arek' add --title "$title" --when "$duration $hour:$minutes" --duration 60 --description "$description" --where ' ' --reminder '10m popup'
else
	duration_in_minutes=$((duration*60))
	echo $duration_in_minutes
	echo "$date $hour:$minutes"
	gcalcli --config-folder="/home/miro/.config/gcalcli" --calendar 'arek' add --title "$title" --when "$date $hour:$minutes" --duration $duration_in_minutes --description "$description" --where ' ' --reminder '10m popup'
fi

dunstify "added event - $title"
# zenity --info --text="$title" --display=:0.0

# current_hour=$(date +"%H")
# elif [ $hour lt $current_hour ] && [$date eq date +"%m/%d/%Y"]; then
# 	echo "tomorrow"
# 	duration_in_minutes=$((duration*60))
# 	gcalcli --config-folder="/home/miro/.config/gcalcli" --calendar 'arek' add --title "$title" --when "$date $hour:$minutes" --duration $duration_in_minutes --description "$description" --where ' ' --reminder '10m popup'

# timexp='^[0-9]{2}:[0-9]{2}'
# if [ -z "$where" ]; then
	# where=" "
# fi
# hour=$(zenity --scale --text="Wybór minut" --min-value=1 --max-value=24 --value=12)
# minutes=$(zenity --scale --text="Wybór minut" --value=30 --max-value=60 --step=15)

