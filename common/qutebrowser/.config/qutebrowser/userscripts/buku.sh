#!/bin/bash
buku --debug --add "$QUTE_URL" "$(buku -t --np | awk '{print $2}' | rofi -dmenu -p 'comma for multiple tags' )" --title "$QUTE_TITLE" >> /dev/null 2>&1;
echo "message-info 'Bookmark added to Buku!'" >> "$QUTE_FIFO"
