rofi -dmenu -p "dictionary:" | trans -sp en: -show-prompt-message n -show-languages n -o /tmp/dic.txt
st -e less /tmp/dic.txt
