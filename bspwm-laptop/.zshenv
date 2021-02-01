# export CLIPSTER_HISTORY_SIZE=1000

# Default Apps
# export EDITOR="nvim"
# export READER="zathura"
# export VISUAL="envim"
# export TERMINAL="kitty"
# export BROWSER="firefox"
# export VIDEO="smplayer"
# export IMAGE="sxiv"
# export OPENER="xdg-open"
# export PAGER="less"
# export WM="bspwm"
# fix java apps with bspwm
export _JAVA_AWT_WM_NONREPARENTING=1
if [ -n "`which wmname`" ]; then
    wmname LG3D
fi
