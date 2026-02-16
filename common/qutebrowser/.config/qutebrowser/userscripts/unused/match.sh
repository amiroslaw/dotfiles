#!/bin/bash
# exexutes when url pattern match
declare -A matchtable

# -------- CONFIGURE -----------
# Table of greps and related commands to execute
# 	    <  grep pattern >    < qute command >
matchtable["youtube.com/watch"]=":spawn mpv {url}"
matchtable["twitch.tv/"]=":spawn livestreamer {url}"

# -------- DONT EDIT -----------
# start process
# check regexes
match_url=$QUTE_URL
for key in "${!matchtable[@]}"; do
	# match url to grep table, if found
	# append command to queue
	# remove tab to avoid repeated executions
	if echo "$match_url" | grep "$key"; then 
		echo ${matchtable[$key]} >> "$QUTE_FIFO"
		echo ":close" >> "$QUTE_FIFO"
	fi
done

# add some interval to prevent overload
# restart script on the end of the command queue
sleep 0.1
echo ":spawn $BASH_SOURCE" >> "$QUTE_FIFO"

