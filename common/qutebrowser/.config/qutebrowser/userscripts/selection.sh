#!/bin/sh

search_engine_file="$QUTE_CONFIG_DIR/config.py"

search_engine_start="c.url.searchengines"

# check for empty selection and exit
[ -z "$QUTE_SELECTED_TEXT" ] && exit 0

# notify-send "raw_search_engines"
raw_search_engines=$(awk "/$search_engine_start/{p=1}/^ *$/{p=0}p" "$search_engine_file")

# isolate lines with search engine definitions
definitions=$(echo "$raw_search_engines" | grep --basic-regexp ',$')

# get search engine abbreviations
abbreviations=$(echo "$definitions" | grep -oE "'\w+'" | tr -d \')

# select engine from menu
search_engine=$(echo "$abbreviations" | dmenu -p "search engine")

# search selected text with search engine in new tab
echo "open -t $search_engine $QUTE_SELECTED_TEXT" >> "$QUTE_FIFO"
