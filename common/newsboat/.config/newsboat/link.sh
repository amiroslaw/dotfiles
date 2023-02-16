#!/bin/sh

# Feed script a url or file location.
# If an image, it will view in sxiv,
# if a video or gif, it will view in mpv
# if a music file or pdf, it will download,
# otherwise it opens link in browser.
if [ -z "$1" ]; then
	url="$(xclip -o)"
else
	url="$1"
fi

case "$url" in
	*mkv|*webm|*mp4|*youtube.com/watch*|*youtube.com/playlist*|*youtube.com/shorts*|*youtu.be*|*hooktube.com*|*bitchute.com*|*odysee.com*)
		setsid -f mpv.lua --videoplay "$url" >/dev/null 2>&1 ;;
		# notify-send "newboat mpv" && setsid -f url.lua video "$url" >/dev/null 2>&1 ;;
	*.png*|*.jpg*|*.jpe*|*.jpeg*|*.gif*)
		curl -sL "$url" > "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" && sxiv -a "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 & ;;
	*pdf|*cbz|*cbr)
		curl -sL "$url" > "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 & ;;
	# *mp3|*flac|*opus|*mp3?source*)
		# TODO IDK what is qndl
		# qndl "$url" 'curl -LO'  >/dev/null 2>&1 ;;
	*)
		[ -f "$url" ] && setsid -f "$TERMINAL" -e "$EDITOR" "$url" >/dev/null 2>&1 || setsid -f "$BROWSER" "$url" >/dev/null 2>&1
		# rdrview opens less
		# setsid -f rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" -B w3m "$url" 
		# setsid -f rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "$url" 
		# setsid -f rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "$url" -H /tmp/newsboat.html && setsid -f "$BROWSER" /tmp/newsboat.html >/dev/null 2>&1
		#readable -o! /tmp/newshoat.html "$url" >/dev/null 2>&1 && setsid -f "$BROWSER" /tmp/newshoat.html >/dev/null 2>&1
esac
