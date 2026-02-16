#!/usr/bin/env bash
PROJECT_PATH=~/eversis/projects/neo
module=$( { echo 'logs' & echo 'theme' & echo 'all' & ls "$PROJECT_PATH/modules" ; } | rofi -dmenu -i)

if [[ "logs" == "$module" ]]; then
	termite -t "logs" -e "less /tmp/deploy-neo.log"
elif [[ "theme" == "$module" ]]; then
	if "$PROJECT_PATH/gradlew" -p "$PROJECT_PATH/wars" deploy > /tmp/deploy-neo.log; then
		notify-send "theme deployed"
	else
		notify-send -u critical "theme deploy error"
	fi
elif [[ "all" == "$module" ]]; then
	if "$PROJECT_PATH/gradlew" -p "$PROJECT_PATH/" deploy > /tmp/deploy-neo.log; then
		notify-send "project deployed"
	else
		notify-send -u critical "project deploy error"
	fi
else
	if "$PROJECT_PATH/gradlew" -p "$PROJECT_PATH/modules/$module" deploy > /tmp/deploy-neo.log; then
		notify-send "$module deployed"
	else
		notify-send -u critical "$module deploy error"
	fi
fi

