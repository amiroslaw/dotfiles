# -------------------------------------------------------------------------
#                       sources
# -------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source "${HOME}/.config/aliases"

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

zstyle ':completion:*' menu select
zmodload -i zsh/complist
# expand alias with TAB it can expand $()
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
#                       # ZGENOM
# -------------------------------------------------------------------------
source "${HOME}/.config/zgenom/zgenom.zsh"
if ! zgenom saved; then
	# zgenom ohmyzsh #adds all aliases
	zgenom ohmyzsh plugins/sudo 
	zgenom ohmyzsh plugins/history 
	zgenom ohmyzsh plugins/web-search 
	zgenom ohmyzsh plugins/colored-man-pages
	# zgenom ohmyzsh plugins/fasd # has error
	zgenom load wookayin/fzf-fasd
	zgenom load zsh-users/zsh-completions
	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zsh-users/zsh-syntax-highlighting
	zgenom load romkatv/powerlevel10k powerlevel10k
	zgenom load arzzen/calc.plugin.zsh
	zgenom load urbainvaes/fzf-marks # mark alias_name ctrl-g TODO check if it works
	zgenom load ptavares/zsh-sdkman
	# zgenom load jeffreytse/zsh-vi-mode # can override some keybindings
	# zgenom ohmyzsh plugins/git 
	# zgenom load ChrisPenner/copy-pasta #alternative xclip-copyfile; xclip-pastefile

	zgenom save
    zgenom compile "$HOME/.zshrc" # Compile your zsh files
fi

# -------------------------------------------------------------------------
#                       bindkey
# -------------------------------------------------------------------------
# autosuggestions
bindkey -e
bindkey '\el' autosuggest-accept
bindkey '\ex' autosuggest-execute
bindkey '\ec' autosuggest-clear

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char

source ~/.config/fzf/fzf.zsh
source ~/.config/broot/launcher/bash/br

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# To customize prompt, run `p10k configure` or edit ~/.config/p10k.zsh.
[[ ! -f ~/.config/p10k.zsh ]] || source ~/.config/p10k.zsh

# Needed it if the plugin is not loaded
eval "$(fasd --init auto)"
# shuf -n 1 $CONFIG/logs/dictionary/enpl-dictionary.txt

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/miro/.local/share/sdkman"
[[ -s "/home/miro/.local/share/sdkman/bin/sdkman-init.sh" ]] && source "/home/miro/.local/share/sdkman/bin/sdkman-init.sh"

if (( $(uname --nodename) == "hp" )) ; then
	bindkey -e
fi
