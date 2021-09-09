#!/usr/bin/env sh
# shows if the window is in monocle layout but is not a single monocle
# add current and chane only if it is in a focused window
# bspc query -T -d $(bspc query -D -d focused) 
            # echo " %{F"#bd2c40"} M "

userLayout() {
    case $(bspc query -T -d | jq -r .userLayout) in
        monocle)
            echo "M"
            ;;
        *)
            echo ""
            ;;
    esac
}

bspc subscribe report | while read -r line; do
    userLayout
done
