#!/usr/bin/env bash

rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
#rofi -modi "clipboard:greenclip print" -show clipboard
# rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}' ; sleep 0.5; xdotool type (xclip -o -selection clipboard)
