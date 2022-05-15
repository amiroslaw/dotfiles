#!/bin/bash
# Utils for links
# List of the actions:
# 		menu - show rofi with available actions
# 		audio - downlad audio via youtube-dl 
# 		yt - downlad video via youtube-dl 
# 		tor - create torrent file form a magnetlink
# 		kindle - downlad video via gallery-dl 
# 		read - convert website to asciidoc and show it in 'reader view' mode
# 		wget - downlad file via wget
# 		video - play video in video player (mpv)
# 		gallery - downlad images via gallery-dl 

case "$1" in
	"audio" )
		url.lua audio "$QUTE_URL"
	;;
	"yt" )
		url.lua yt "$QUTE_URL"
	;;
	"tor" )
		url.lua tor "$QUTE_URL"
	;;
	"kindle" )
		url.lua kindle "$QUTE_URL"
	;;
	"read" )
		url.lua read "$QUTE_URL"
	;;
	"speed" )
		url.lua gallery "$QUTE_URL"
	;;
	"wget" )
		url.lua wget "$QUTE_URL"
	;;
	"video" )
		url.lua video "$QUTE_URL"
	;;
	"gallery" )
		url.lua gallery "$QUTE_URL"
	;;
	* )
		url.lua menu
	;;
esac
