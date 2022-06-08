#!/bin/bash
tmpPlaylist="/tmp/mpvplaylist.m3u"
dirPlaylists="$HOME/Templates/mpvlists"

case "$1" in
	"play" )
		mpv --profile=stream --playlist="$tmpPlaylist" 
		mkdir -p "$dirPlaylists"
		mv "$tmpPlaylist" "$dirPlaylists"/"$(date +"%FT%H%M")".m3u
		rm -f "$tmpPlaylist"
		;;
	"push" )
		echo "$2" >> "$tmpPlaylist"
		;;
	"audio" )
		st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M "$2"
		;;
	"audiolist" )
		mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist="$tmpPlaylist"
		mkdir -p "$dirPlaylists"
		mv "$tmpPlaylist" "$dirPlaylists"/"$(date +"%FT%H%M")".m3u
		rm -f "$tmpPlaylist"
		;;
	* )
		mpv --profile=stream "$1"
		# mpv --fs --no-terminal --keep-open=yes --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --slang=en --ytdl-raw-options="write-auto-sub=,sub-lang=en,yes-playlist=" --ytdl-format="bestvideo[height<=?1080][vcodec!=vp9]+bestaudio/best" --input-ipc-server=/tmp/mpvsocket "$1"
		;;
esac
