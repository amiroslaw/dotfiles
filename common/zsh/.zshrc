# -------------------------------------------------------------------------
#                       sources
# -------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source ~/.config/fzf/fzf.zsh
source ~/.config/broot/launcher/bash/br
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${HOME}/.config/zgenom/sources/urbainvaes/fzf-marks/___/fzf-marks.plugin.zsh"
# FZF_MARKS_JUMP="^z"
source $HOME/.config/aliases

# -------------------------------------------------------------------------
#                       # Options section
# -------------------------------------------------------------------------
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

# expand alias with TAB
zstyle ':completion:*' completer _expand_alias _complete _ignored
# bindkey "mykeybinding" _expand_alias

# -------------------------------------------------------------------------
#                       history
# -------------------------------------------------------------------------
setopt HIST_FIND_NO_DUPS
# following should be turned off, if sharing history via setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
#setopt appendhistory
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=$HISTSIZE
# ignore duplicats
export HISTCONTROL=ignoreboth

# -------------------------------------------------------------------------
#                       bindkey
# -------------------------------------------------------------------------
# autosuggestions
bindkey '^l' autosuggest-accept
bindkey '^j' autosuggest-execute
bindkey '^ ' autosuggest-clear

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

# -------------------------------------------------------------------------
#                       # ZGENOM didn't work in the top of the zshrc
# -------------------------------------------------------------------------
source "${HOME}/.config/zgenom/zgenom.zsh"
if ! zgenom saved; then
	zgenom ohmyzsh

	zgenom ohmyzsh plugins/fasd 
	zgenom ohmyzsh plugins/sudo 
	zgenom ohmyzsh plugins/history 
	zgenom ohmyzsh plugins/web-search 
	zgenom ohmyzsh plugins/colored-man-pages
	# zgenom ohmyzsh plugins/git 
	
	zgenom load zsh-users/zsh-completions
	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zsh-users/zsh-syntax-highlighting
	zgenom load romkatv/powerlevel10k powerlevel10k
	zgenom load jeffreytse/zsh-vi-mode
	zgenom load arzzen/calc.plugin.zsh
	zgenom load ChrisPenner/copy-pasta
	zgenom load urbainvaes/fzf-marks
	zgenom load ptavares/zsh-sdkman

	zgenom save
 # Compile your zsh files
    zgenom compile "$HOME/.zshrc"
fi

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/p10k.zsh ]] || source ~/.config/p10k.zsh

# shuf -n 1 $CONFIG/logs/dictionary/enpl-dictionary.txt
# I don't know if i use it
# eval "$(fasd --init auto)"
