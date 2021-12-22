#!/usr/bin/env bash
# works only with 2 monitors
# https://www.reddit.com/r/bspwm/comments/hs66ss/swap_all_windows_between_two_workspaces/
bspc node @^1:focused:/ -s @^2:focused:/ || \
bspc node @^1:focused:/ -d ^2:focused || \
bspc node @^2:focused:/ -d ^1:focused

# https://www.reddit.com/r/bspwm/comments/hs66ss/swap_all_windows_between_two_workspaces/

# src_desktop_name="$(bspc query -D -d '^1:^1' --names)" || exit 1
# dst_desktop_name="$(bspc query -D -d '^2:^1' --names)" || exit 1
# bspc desktop '^1:^1' -n "$dst_desktop_name" -s '^2:^1'
# bspc desktop '^1:^1' -n "$src_desktop_name"
