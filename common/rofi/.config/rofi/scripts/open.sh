#!/usr/bin/env bash

ROFI_OPTIONS=(-theme-str 'window {width:  80%;}' -l 25 -i -dmenu -multi-select -monitor -4 -matching normal)
STREAM_PLAYLIST=~/Templates/mpvlists

case "$1" in
	fasd) fasd -Rfl | rofi "${ROFI_OPTIONS[@]}" -p "open fasd files:" | xargs -r -P 0 -I {} xdg-open {} ;;
	fasd-dir) fasd -Rdl | rofi "${ROFI_OPTIONS[@]}" -p "open fasd dir:" | xargs -r -P 0 -I {} xdg-open {} ;;
	file) fd --type f | rofi "${ROFI_OPTIONS[@]}" -p "open files:" | xargs -r -P 0 -I {} xdg-open {} ;;
	file-hidden) fd --hidden --type f | rofi "${ROFI_OPTIONS[@]}" -p "open hidden files:" | xargs -r -P 0 -I {} xdg-open {} ;;
	dir) fd --type d --follow | rofi "${ROFI_OPTIONS[@]}" -p "dir" | xargs -r -P 0 -I {} xdg-open {} ;;
	dir-hidden) fd --type d --hidden | rofi "${ROFI_OPTIONS[@]}" -p "open hidden dir:" | xargs -r -P 0 -I {} xdg-open {} ;;
	video) fd --follow --base-directory="$HOME/Videos" --search-path="$HOME/Videos" --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg | rofi "${ROFI_OPTIONS[@]}" -p "open video:" | awk '{print "\""$0"\""}' | xargs -r mpv ;;
	course) fd --type=f -e m3u --base-directory="/media/multimedia/kursy/" --search-path="/media/multimedia/kursy/" | rofi "${ROFI_OPTIONS[@]}" -p "open course:" | awk '{print "\""$0"\""}' | xargs -r mpv ;;
	yt) cd "$STREAM_PLAYLIST" && mpv --profile=stream "$(ls -t | grep -e "video" | rofi "${ROFI_OPTIONS[@]}")";;
	audio) cd "$STREAM_PLAYLIST" && st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist="$(ls -t | grep -e "audio" | rofi "${ROFI_OPTIONS[@]}")"
esac
	# fd and find can't read environment  variable
	# course) fd --type=f -e m3u --base-directory="$COURSES" --search-path="$COURSES" | rofi "${ROFI_OPTIONS[@]}" -p "open course:" | awk '{print "\""$0"\""}' | xargs -r mpv ;;
	# video) cd "$HOME/Videos" && fd --follow  --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg --search-path "$HOME/Videos" | awk -v pattern="$HOME/Videos" '{gsub(pattern,".", $0); print $0}' | rofi "${ROFI_OPTIONS[@]}" -p "open video:" | awk '{print "\""$0"\""}' | xargs -r "$VIDEO" ;;
	# course) cd "$COURSES" && fd --follow  --type=f -e m3u --search-path "$COURSES" | awk -v pattern="$COURSES" '{gsub(pattern,".", $0); print $0}' | rofi "${ROFI_OPTIONS[@]}" -p "open course:" | awk '{print "\""$0"\""}' | xargs -r mpv ;;
# fd --follow  --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg --search-path ~/Videos | rofi -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r $VIDEO

# xdg-open "$(fd -t f | rofi -dmenu -multi-select -monitor -4 -matching fuzzy)" &>/dev/null
# fd --follow  --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg --search-path ~/Videos | rofi -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r $VIDEO

# fd --follow --full-path --type=f -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg ~/Videos | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r $VIDEO
# find
# find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:" | awk '{print "\""$0"\""}' | xargs -r xdg-open
# xdg-open "$(find -L ~/Videos -type f | rofi -threads 0 -width 100 -lines 30 -multi-select -dmenu -i -p "locate:")"
# xdg-open "$(locate ~/Documents ~/Downloads | rofi -threads 0 -width 100 -dmenu -i -p "locate:")" // only one file
