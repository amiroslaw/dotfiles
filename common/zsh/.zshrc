# -------------------------------------------------------------------------
#                       p10k
# -------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/p10k.zsh ]] || source ~/.config/p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

source "${HOME}/.config/aliases"
autoload -Uz compinit #for taskwarrior fix
compinit

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
	zgenom ohmyzsh plugins/taskwarrior
	zgenom ohmyzsh plugins/dirhistory
	# zgenom ohmyzsh plugins/fasd # has error
	# zgenom load wookayin/fzf-fasd # i have my own fzf bindings
	zgenom load lincheney/fzf-tab-completion # breaks some completions
	zgenom load zsh-users/zsh-completions
	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zsh-users/zsh-syntax-highlighting
	zgenom load romkatv/powerlevel10k powerlevel10k
	zgenom load arzzen/calc.plugin.zsh
	zgenom load urbainvaes/fzf-marks # mark alias_name; fzm to cd
	zgenom load MichaelAquilina/zsh-you-should-use
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


export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

fasd_cache="$HOME/.cache/fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
    zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# shuf -n 1 $CONFIG/logs/dictionary/enpl-dictionary.txt

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/miro/.local/share/sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export MVND_HOME="/opt/mvnd" 
[[ -s '$MVND_HOME/bin/mvnd-bash-completion.bash' ]] && 'source $MVND_HOME/bin/mvnd-bash-completion.bash'

source ~/.config/fzf/fzf.zsh
source ~/.config/broot/launcher/bash/br
source ~/.config/zgenom/sources/lincheney/fzf-tab-completion/___/zsh/fzf-zsh-completion.sh
bindkey '^I' fzf_completion

eval $(thefuck --alias)
