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
		url.lua audio "$2"
	;;
	"yt" )
		url.lua yt "$2"
	;;
	"tor" )
		url.lua tor "$2"
	;;
	"kindle" )
		url.lua kindle "$2"
	;;
	"read" )
		url.lua read "$2"
	;;
	"speed" )
		url.lua speed "$2"
	;;
	"wget" )
		url.lua wget "$2"
	;;
	"video" )
		url.lua video "$2"
	;;
	"gallery" )
		url.lua gallery "$2"
	;;
	"firefox" )
		firefox "$2"
	;;
	* )
		url.lua menu
	;;
esac
