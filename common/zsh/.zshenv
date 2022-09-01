## changing default config folder
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export GTK2_RC_FILES="$HOME/.config/gtkrc-2.0"
export UNCRUSTIFY_CONFIG="$XDG_CONFIG_HOME"/uncrustify/uncrustify.cfg
export SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc
export SDKMAN_DIR="$XDG_DATA_HOME"/sdkman
export GOPATH="$XDG_DATA_HOME"/go
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export HISTFILE="${XDG_STATE_HOME}"/bash/history

export TODO_DIR="$NOTE/Documents/notebook/todo"
export TODOTXT_DEFAULT_ACTION=ls

# didn't move
# export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
# compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
