#!/bin/sh
# sauron - external fzf menu for running all links
# fork from https://github.com/NapoleonWils0n/cerberus/blob/master/ytfzf/ytfzf-taskspooler.org

# if script is run without arguments exit
# TODO sauron.sh < /tmp/newsboat-links wont' work
[ $# -gt 0 ] || exit

# input set to args passed to script
input=$(printf "%s\n" "$@")

# kindle
kindle() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --kindle --email "${line}" 1>/dev/null
    done
}

# download with yt-dlp
dl_video() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --dlVideo "${line}" 1>/dev/null
    done
}

# download with yt-dlp
dl_audio() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --dlAudio "${line}" 1>/dev/null
    done
}

# mpv fullscreen and queue
fullscreen() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --mpvFullscreen "${line}" 1>/dev/null
    done
}

popup() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --mpvPopup "${line}" 1>/dev/null
    done
}

audio() {
    printf "%s\n" "${input}" | \
    while read line
    do
		setsid -f url.lua --mpvAudio "${line}" 1>/dev/null
    done
}
# fzf prompt variables spaces to line up menu options
audio='audio        - mpd play audio'
popup='popup        - mpv play popup video' 
fullscreen='fullscreen   - mpv play fullscreen' 
dl_video='dl-video     - yt-dlp download video'
dl_audio='dl-audio     - yt-dlp download audio'
kindle='kindle        - download kindle article' 

# fzf prompt to specify function to run on links from ytfzf
menu=$(printf "%s\n" \
	      "${audio}" \
	      "${popup}" \
	      "${fullscreen}" \
	      "${dl_video}" \
	      "${dl_audio}" \
	      "${kindle}" \
	      | fzf --delimiter='\n' --prompt='Pipe links to: ' --info=inline --layout=reverse --no-multi)

# case statement to run function based on fzf prompt output
case "${menu}" in
   audio*) audio;;
   popup*) popup;;
   fullscreen*) fullscreen;;
   dl_video*) dl_video;;
   dl_audio*) dl_audio;;
   kindle*) kindle;;
   *) exit;;
esac
