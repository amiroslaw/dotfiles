#!/usr/bin/env bash
# https://github.com/nocturnalbeast/polybar-bspwm-taskbar-module
# add tabs bar
# exec = taskbar --activebg "#000" --inactivebg "#303030" --fg "#eaeaea" --separator "·" --monitor
# add moniotr name if you want to have multimoniotor support; 
# with some monitors name it can be a problem https://github.com/baskerville/bspwm/issues/552
# DVI-D-0
# DVI-I-0

ACTIVE_BG_COLOR="#323232"
INACTIVE_BG_COLOR="#222"
FG_COLOR="#d0d0d0"
SEPARATOR=""
MONITOR=""

while [[ $# -gt 0 ]]; do
    KEY="$1"
    case $KEY in
        --activebg) ACTIVE_BG_COLOR="$2";;
        --inactivebg) INACTIVE_BG_COLOR="$2";;
        --fg) FG_COLOR="$2";;
        --separator) SEPARATOR="$2";;
        --monitor) MONITOR="$2";;
        *) echo "Unknown option $KEY.";;
    esac
    shift
    shift
done
LAST_DESKTOP=1

while read LINE; do
	MONITOR_FOCUSED=$(bspc query -N -n .window -d focused -m $MONITOR)
	if [[ -z $MONITOR_FOCUSED ]]
	then
		mapfile -t WINDOW_LIST < <( bspc query -N -n .window -d $LAST_DESKTOP -m $MONITOR )
	else
		mapfile -t WINDOW_LIST < <( bspc query -N -n .window -d focused -m $MONITOR )
		LAST_DESKTOP=$(bspc query -D -d focused -m $MONITOR)
	fi
    if [ ${#WINDOW_LIST[@]} -eq 0 ]; then
        echo "%{B$INACTIVE_BG_COLOR}%{F$FG_COLOR} - %{u-}"
    else
        MODULE_STR=""
        for WINDOW in "${WINDOW_LIST[@]}"; do
            FOCUS="$( bspc query -N -n )"
            [[ "$FOCUS" == "$WINDOW" ]] && BG_COLOR="$ACTIVE_BG_COLOR" || BG_COLOR="$INACTIVE_BG_COLOR"
            TITLE="$( xdotool getwindowname $WINDOW | sed 's/^.*-\s//g' | sed -E 's/(–.*$)?(\s?\(.*\))?//g' )"
            MAX_LENGTH=$(((${#TITLE}*5)/100))
            [ $MAX_LENGTH -gt 0 ] && TITLE="$( echo $TITLE | sed -E "s/.{$MAX_LENGTH}$/.../" )" || TITLE=$TITLE
            MODULE_STR="${MODULE_STR}%{A1:bspc node -f $WINDOW:}%{B$BG_COLOR}%{F$FG_COLOR} $SEPARATOR $TITLE%{A}%{u-} "
        done
        echo -e "$MODULE_STR\n\c"
    fi
done < <( echo && bspc subscribe node_focus node_add node_remove desktop_focus monitor_focus )
if [ -z "$(bspc query -N -n .window -d focused)" ]; then
	echo "%{B#323232}%{F#d0d0d0} - %{u-}"
fi

for WINDOW in $(bspc query -N -n .window -d focused -m $MONITOR)
do
	FOCUS=`bspc query -N -n`
	[[ "$FOCUS" == "$WINDOW" ]] && COLOR="#222" || COLOR="#323232"
	TITLE=$(xdotool getwindowname $WINDOW | sed 's/^.*-\s//g' | sed -E 's/(–.*$)?(\s?\(.*\))?//g')
	MAX_LENGTH=$(((${#TITLE}*5)/100))
	[ $MAX_LENGTH -gt 0 ] && TITLE=`echo $TITLE | sed -E "s/.{$MAX_LENGTH}$/.../"` || TITLE=$TITLE
	echo -e "%{A1:bspc node -f $WINDOW:}%{B$COLOR}%{F#d0d0d0}  $TITLE%{A}%{u-} \c"
done

