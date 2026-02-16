#!/bin/bash 
# https://www.reddit.com/r/newsboat/comments/yz4zzl/bash_script_to_easily_add_youtube_channels_to/
# urls should be grouped by tags if this format `#{{{ tag-name`
# doesn't handle multiple tags
 
NB_URLS_FILE_PATH=$(readlink -f ~/.config/newsboat/urls) 
CHANNEL_NAME=$(echo "" | rofi -dmenu -p "Channel name")  

# should be head without head
CHANNEL_ID="$(curl -s ${QUTE_URL} | grep -o -P '"channelId":".{0,24}"' | tail -c 26 | head -c 24)"   

[ -z "${CHANNEL_ID}" ] && exit 1   
TAG=$(awk '/^#{{{/ {print $2}' "${NB_URLS_FILE_PATH}" | rofi -dmenu -p "Tag")   
[ -n "${TAG}" ] && \
{     
NB_LINE="https://www.youtube.com/feeds/videos.xml?channel_id=${CHANNEL_ID} \"~${CHANNEL_NAME}\"  ${TAG} yt";     
sed -i "/^#{{{ ${TAG}$/a ${NB_LINE}" "${NB_URLS_FILE_PATH}"
notify-send --icon=dialog-information "Successfully added the YT channel!";   
# echo "message-info 'Bookmark added to Buku!'" >> "$QUTE_FIFO"
} 
