#!/usr/bin/luajit
-- change it to lua in order to dynamically search from pointed text 
-- search_engine_file=os.getenv("QUTE_CONFIG_DIR") .. "/config.py"
search_engine_file="/home/miro/.config/qutebrowser/config.py"
	 
search_engine_start="c.url.searchengines"

file = io.open(search_engine_file, 'r')
print(file:read())
print(file:seek())
	-- if line:find(search_engine_start) then
	-- end



-- [ -z "$QUTE_SELECTED_TEXT" ] && exit 0

-- if [ -n "$1" ]; then
-- 	echo "open -b $1 $QUTE_SELECTED_TEXT" >> "$QUTE_FIFO"
-- 	exit 0
-- fi

-- # notify-send "raw_search_engines"
-- raw_search_engines=$(awk "/$search_engine_start/{p=1}/^ *$/{p=0}p" "$search_engine_file")
--
-- # isolate lines with search engine definitions
-- definitions=$(echo "$raw_search_engines" | grep --basic-regexp ',$')
--
-- # get search engine abbreviations
-- abbreviations=$(echo "$definitions" | grep -oE "'\w+'" | tr -d \')
--
-- # select engine from menu
-- search_engine=$(echo "$abbreviations" | dmenu -p "search engine")
--
-- # search selected text with search engine in new tab
-- echo "open -b $search_engine $QUTE_SELECTED_TEXT" >> "$QUTE_FIFO"
