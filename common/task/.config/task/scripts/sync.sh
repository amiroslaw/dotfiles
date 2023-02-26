#!/bin/bash
taskrc="$HOME/.config/task/taskrc"
taskData="$HOME/.local/share/task"
sed -i 's/wait:"253402124400"/wait:"2147382000"/g' $taskData/undo.data $taskData/completed.data $taskData/pending.data
sed -i 's/"wait":"99991229T230000Z"/"wait":"20370117T230000Z"/g' $taskData/backlog.data

task sync

# sync with inthe
# echo "include $HOME/Documents/Ustawienia/stow-private/task/inthe/inthe-config" >> "$taskrc"
# task sync
# sed -i '$,$ d' "$taskrc"
