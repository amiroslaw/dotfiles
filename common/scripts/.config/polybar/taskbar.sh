#!/usr/bin/env bash
# https://github.com/nautilor/polybar-bspwm-taskbar-module

if [ -z "$(bspc query -N -n .window -d focused)" ]; then
	echo "%{B#323232}%{F#d0d0d0} - %{u-}"
fi

for WINDOW in $(bspc query -N -n .window -d focused)
do
	FOCUS=`bspc query -N -n`
	[[ "$FOCUS" == "$WINDOW" ]] && COLOR="#222" || COLOR="#323232"
	TITLE=$(xdotool getwindowname $WINDOW | sed 's/^.*-\s//g' | sed -E 's/(–.*$)?(\s?\(.*\))?//g')
	MAX_LENGTH=$(((${#TITLE}*5)/100))
	[ $MAX_LENGTH -gt 0 ] && TITLE=`echo $TITLE | sed -E "s/.{$MAX_LENGTH}$/.../"` || TITLE=$TITLE
	echo -e "%{A1:bspc node -f $WINDOW:}%{B$COLOR}%{F#d0d0d0}  $TITLE%{A}%{u-} \c"
done

# taskbar() {
# }

# bspc subscribe report | while read -r line; do
#     taskbar
# done
