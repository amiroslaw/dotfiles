dunstify "$(gcalcli --nocolor agenda $(date -d "today" +%F) $(date -d "tomorrow" +%F) --config-folder="/home/miro/.config/gcalcli")" -u critical
