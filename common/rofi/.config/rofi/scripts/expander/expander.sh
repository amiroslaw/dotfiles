#!/bin/env bash

# Verify clipster is running, fail otherwise
clipster -o > /dev/null 2>&1
if [ $? -ne 0 ]; then
	notify-send 'Failed to retrieve history from Clipster, please ensure daemon is running!'
	exit 1
fi

DICTIONARY=$(cat "$ROFI/expander/new" $ROFI/expander/en-popular $ROFI/expander/pl-popular) 
# Echo clipboard items to Rofi and save the selection made by user
# better for founding correct word
SELECTION="$(echo -n "$DICTIONARY" | rofi -dmenu -monitor -4 -threads 0 -matching fuzzy -i -lines 20 -width 80 -p 'Select or add: ')"
# faster
# SELECTION="$(echo -n "$DICTIONARY" | rofi -dmenu -monitor -4 -threads 0 -matching prefix -i -lines 20 -width 80 -p 'Select or add: ')"
if [ -n "$SELECTION" ]; then

  # Echo the selection back to primary/selection and clipboard, because not all programs support shift insert in the sam way
  echo -n "$SELECTION" | clipster
  echo -n "$SELECTION" | clipster -c
  # kitty and alacritty paste form clipboard not selection
  xdotool sleep 0.010 key --clearmodifiers shift+Insert

  # remove copied value
  sleep 0.5
  clipster -r
  clipster -rc

  touch "$ROFI/expander/new"
  if ! grep -q "$SELECTION" "$ROFI/expander/new" "$ROFI/expander/en-popular" "$ROFI/expander/pl-popular"; then
	  echo "$SELECTION" >> "$ROFI/expander/new"
  fi
fi

# TODO add frequent, maybe add list with map and update it by awk
# awk 'BEGIN{FS=","} {print $2 "," $1}' slownikfrleks-all.csv > slownik-all.csv
# "$ROFI/expander/frequent"
