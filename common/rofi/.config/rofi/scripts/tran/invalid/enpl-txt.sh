trans -sp en:pl -show-prompt-message n -show-languages n -o /tmp/translate-enpl.txt $1 && 
wait
st -e less /tmp/translate-enpl.txt
