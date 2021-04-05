source $HOME/.config/aliases

## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

export LANG="en_US.UTF-8"
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
#vimode, visual doesn't work, better from ohmyzsh
# bindkey -v
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=$HISTSIZE
# export EDITOR=nvim
# export VISUAL=nvim
# export VISUAL=mousepad
# ignore duplicats
export HISTCONTROL=ignoreboth
setopt HIST_FIND_NO_DUPS
# following should be turned off, if sharing history via setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
#setopt appendhistory

# expand alias with TAB
zstyle ':completion:*' completer _expand_alias _complete _ignored
# bindkey "mykeybinding" _expand_alias

#ZPLUG
export ZPLUG_HOME=~/.config/zplug
# install from aur
source /usr/share/zsh/scripts/zplug/init.zsh
zplug "mafredri/zsh-async", from:"github", defer:0, use:"async.zsh"
# Syntax highlighting for commands, load last
# ohmyzsh
# zplug "zsh-users/zsh-autosuggestions", defer:2, on:"zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3
# Load completion library for those sweet [tab] squares
zplug "lib/completion", from:oh-my-zsh
# zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/fasd",   from:oh-my-zsh
zplug "plugins/sudo",   from:oh-my-zsh
zplug "plugins/history",   from:oh-my-zsh
zplug "plugins/web-search",   from:oh-my-zsh
zplug "plugins/colored-man-pages",   from:oh-my-zsh
zplug "plugins/vi-mode",   from:oh-my-zsh
# Theme!
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug load
# export TERM="xterm-256color"
# set-option -ga terminal-overrides ",xterm-256color:Tc"
# export TERM="screen-256color"
# export TERM="screen-256color-bce"
#POWERLEVEL9K
# https://github.com/bhilburn/powerlevel9k
# https://github.com/bhilburn/powerlevel9k/blob/master/functions/colors.zsh
ZSH_THEME="powerlevel9k/powerlevel9k"
# fonts
# [fonts nerd fonts](https://nerdfonts.com/#downloads)  
# https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-a-powerline-font
POWERLEVEL9K_MODE='nerdfont-complete'
# POWERLEVEL9K_MODE='awesome-patched'
# POWERLEVEL9K_MODE='awesome-fontconfig'
# POWERLEVEL9K_COLOR_SCHEME='light' # chane font color into white
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs dir_writable)
POWERLEVEL9K_OS_ICON_BACKGROUND='magenta3'
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status vi_mode root_indicator background_jobs history time)
POWERLEVEL9K_VI_INSERT_MODE_STRING=''
POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND='purple3'
POWERLEVEL9K_CONTEXT_TEMPLATE='%n'
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='magenta3'
POWERLEVEL9K_STATUS_OK_BACKGROUND='green4'
POWERLEVEL9K_TIME_BACKGROUND='yellow3'
# POWERLEVEL9K_MODE='nerdfont-complete'

# autosuggestions
bindkey '^l' autosuggest-accept
bindkey '^j' autosuggest-execute
bindkey '^ ' autosuggest-clear
# dirhistory doesn't work with vi-mode; move in history via alt + arrows
# vimode 
#bindkey '^?' backward-delete-char
#bindkey '^[[3~' delete-char
# FZF
# ZSH keybinding example; ~/.zshrc
source ~/.config/fzf/fzf.zsh

# CTRL-H - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst pipefail 2> /dev/null
  selected=( $(fc -l 1 | eval "$(__fzfcmd) +s --tac +m -n2..,.. --tiebreak=index --toggle-sort=ctrl-r $FZF_CTRL_R_OPTS -q ${(q)LBUFFER}") )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^H' fzf-history-widget

# I don't know if i use it
eval "$(fasd --init auto)"


# Edit line in vim with ctrl-e: oh-my-zsh do it by esc; v
	# ctr e w fzf to otwieranie folderow
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Change cursor shape for different vi modes.
	# powerlevel9k inform about mode 
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

source /home/miro/.config/broot/launcher/bash/br

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Apply different settigns for different terminals
case $(basename "$(cat "/proc/$PPID/comm")") in
  login)
    	RPROMPT="%{$fg[red]%} %(?..[%?])" 
    	alias x='startx ~/.xinitrc'      # Type name of desired desktop after x, xinitrc is configured for it
    ;;
  *)
        RPROMPT='$(git_prompt_string)'
		# Use autosuggestion
		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  		ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ;;
esac

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/miro/.sdkman"
[[ -s "/home/miro/.sdkman/bin/sdkman-init.sh" ]] && source "/home/miro/.sdkman/bin/sdkman-init.sh"

