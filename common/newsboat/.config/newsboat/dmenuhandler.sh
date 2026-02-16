#!/bin/sh

# Feed this script a link and it will give dmenu
# some choice programs to use to open it.
feed="${1:-$(printf "%s" | dmenu -p 'Paste URL or file path')}"

case "$(printf "videoplay\\npush\\nvideolist\\nvideopopup\\npopuplist\\naudioplay\\naudiolist\\nCopy URL\\nsxiv\\ndlp-audio\\nPDF\\ndlp-video\\nkindle\\nread\\nspeed\\nqueue download\\nqui browser\\nlynx\\w3m" | dmenu -i -p "Open it with?")" in
	"Copy URL") echo "$feed" | xclip -r -sel c ;;
	"queue download") qndl "$feed" 'curl -LO' >/dev/null 2>&1 ;;
	PDF) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
	sxiv) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && sxiv -a "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
	vim) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && setsid -f "$TERMINAL" -e "$EDITOR" "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
	browser) setsid -f "$BROWSER" "$feed" >/dev/null 2>&1 ;;
	lynx) lynx "$feed" >/dev/null 2>&1 ;;
	w3m) w3m "$feed" >/dev/null 2>&1 ;;
	dlp-audio) setsid -f url.lua audio "$feed" >/dev/null 2>&1 ;;
	yt-dlp) setsid -f url.lua yt "$feed" >/dev/null 2>&1 ;;
	kindle) setsid -f url.lua kindle "$feed" >/dev/null 2>&1 ;;
	read) setsid -f url.lua read "$feed" >/dev/null 2>&1 ;;
	speed) setsid -f url.lua speed "$feed" >/dev/null 2>&1 ;;
	push) setsid -f mpv.lua push "$feed" >/dev/null 2>&1 ;;
	videopopup) setsid -f mpv.lua videopopup "$feed" >/dev/null 2>&1 ;;
	popuplist) setsid -f mpv.lua popuplist "$feed" >/dev/null 2>&1 ;;
	audioplay) setsid -f mpv.lua audioplay "$feed" >/dev/null 2>&1 ;;
	audiolist) setsid -f mpv.lua audiolist "$feed" >/dev/null 2>&1 ;;
	videoplay) setsid -f mpv.lua videoplay "$feed" >/dev/null 2>&1 ;;
	videolist) setsid -f mpv.lua videolist "$feed" >/dev/null 2>&1 ;;
esac


# case "$(printf "Copy URL\\nsxiv\\nsetbg\\nPDF\\nbrowser\\nlynx\\nvim\\nmpv\\nmpv loop\\nmpv float\\nqueue download\\nqueue yt-dl\\nqueue yt-dl audio" | dmenu -i -p "Open it with?")" in
# 	"copy url") echo "$feed" | xclip -selection clipboard ;;
# 	mpv) setsid -f mpv -quiet "$feed" >/dev/null 2>&1 ;;
# 	"mpv loop") setsid -f mpv -quiet --loop "$feed" >/dev/null 2>&1 ;;
# 	"mpv float") setsid -f "$TERMINAL" -e mpv --geometry=+0-0 --autofit=30%  --title="mpvfloat" "$feed" >/dev/null 2>&1 ;;
# 	"queue yt-dl") qndl "$feed" >/dev/null 2>&1 ;;
# 	"queue yt-dl audio") qndl "$feed" 'youtube-dl --add-metadata -icx -f bestaudio/best' >/dev/null 2>&1 ;;
# 	"queue download") qndl "$feed" 'curl -LO' >/dev/null 2>&1 ;;
# 	PDF) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
# 	sxiv) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && sxiv -a "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
# 	vim) curl -sL "$feed" > "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")" && setsid -f "$TERMINAL" -e "$EDITOR" "/tmp/$(echo "$feed" | sed "s/.*\///;s/%20/ /g")"  >/dev/null 2>&1 ;;
# 	setbg) curl -L "$feed" > $XDG_CACHE_HOME/pic ; xwallpaper --zoom $XDG_CACHE_HOME/pic >/dev/null 2>&1 ;;
# 	browser) setsid -f "$BROWSER" "$feed" >/dev/null 2>&1 ;;
# 	lynx) lynx "$feed" >/dev/null 2>&1 ;;
# esac
