# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "~/.config/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.config/fzf/shell/key-bindings.zsh"

# Doesn't matter if fzf was installed from aur
# Setup fzf
# ---------
# if [[ ! "$PATH" == */home/miro/.fzf/bin* ]]; then
#   export PATH="$PATH:/home/miro/.config/fzf/bin"
# fi

# Man path
# --------
# if [[ ! "$MANPATH" == */home/miro/.config/fzf/man* && -d "/home/miro/.config/fzf/man" ]]; then
#   export MANPATH="$MANPATH:/home/miro/.config/fzf/man"
# fi

