#!/bin/bash
if [[ -z "$@" ]]; then
    find $HOME/.config/rofi/scripts/tran -type f
else
    bash -c $@
fi
