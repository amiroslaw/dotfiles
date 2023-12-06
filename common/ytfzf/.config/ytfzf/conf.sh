keep_cache=1

video_pref=1080
# video_player="sauron.sh"

# load_url_handler()
video_player () {
   #check if detach is enabled
   case "$is_detach" in
   #    #disabled
      0) sauron.sh "$@" ;;
   #    #enabled
      1) setsid -f sauron.sh "$@" > /dev/null 2>&1 ;;
     esac
}

# The preference to use for youtube-dl in mpv.
# $ytdl_pref
# default: $video_pref+$audio_pref/best/$video_pref/$audio_pref
# thumbnail_viewer="catimg"
# --async-thumbnails      Download thumbnails asynchronously.
#
# $ytdl_opts - doesn't work
# The command-line options to pass to youtube-dl when downloading.
# ytdl_opts="write-auto-sub=,sub-lang=en"

# is_detach
# Whether or not to detach the video player from the terminal.
# default: 0
#
#--url-handler-opts=opts
# Opts to pass to the url handler, by default this will pass extra opts to mpv. 
# ytfzf -D --url-handler-opts="--x11-name=videopopup --profile=stream-popup"


# -------------------------------------------------------------------------
#                       shortcuts
# -------------------------------------------------------------------------
#$video_shortcut
# The shortcut to watch the selected videos.
# default: alt-v
#
# $audio_shortcut
# The shortcut to listen to the selected videos.
# default: alt-m
