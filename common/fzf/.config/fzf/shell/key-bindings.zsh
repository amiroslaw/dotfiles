#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
# Fork from https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh

# -------------------------------------------------------------------------
#                       shortcuts
# -------------------------------------------------------------------------
# ALT-p - path both file and directory
# ALT-f - Paste the selected file path(s) into the command line
# ALT-F - Paste the selected file path(s) into the command line  with hidden
# ALT-d - cd into the selected directory
# ALT-D - cd into the selected directory with hidden
# ALT-o - Open or edit the file
# ALT-O - Open or edit the file with hidden
# ALT-e - Open or edit the file from fasd
# ALT-j - cd into the selected directory from fasd
# ALT-h - Paste the selected command from history into the command line
# ALT-q - Kill process
# ALT-w - Run application
# ALT-v - Edit line in vim with ctrl-e: oh-my-zsh do it by esc; v
# ALT-a - aliases
# ALT-m - fzm fzf-marks

# bindkey '\ef' → alt '^F' ctr

# global
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --bind tab:down,shift-tab:up,alt-j:down,alt-k:up,alt-l:accept,ctrl-a:select-all+accept'
export FZF_DEFAULT_COMMAND='fd'

export FZF_PATH_COMMAND='fd'
export FZF_FILE_COMMAND='fd --type f'
export FZF_HIDDEN_FILE_COMMAND='fd --hidden --type f'
export FZF_DIR_COMMAND='fd --type d'
export FZF_HIDDEN_DIR_COMMAND='fd --hidden --type d'
export FZF_FILE_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {}"'
# export FZF_DIR_OPTS
CMD=''
OPTS=''

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'
{

[[ -o interactive ]] || return 0

# Key bindings
# ------------

# ALT-F - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${CMD:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
	CMD="$FZF_FILE_COMMAND"
	OPTS="$FZF_FILE_OPTS"
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '\ef' fzf-file-widget
alias f='fzf-file-widget'

fzf-hidden-file-widget() {
	CMD="$FZF_HIDDEN_FILE_COMMAND"
	OPTS="$FZF_FILE_OPTS"
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-hidden-file-widget
bindkey '\eF' fzf-hidden-file-widget
# alias F='fzf-hidden-file-widget' global for fzf

fzf-path-widget() {
	CMD="$FZF_PATH_COMMAND"
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-path-widget
bindkey '\ep' fzf-path-widget

# ALT-D - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_DIR_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CD_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ed' fzf-cd-widget
alias d='fzf-cd-widget'

# ALT-Shift-D - cd into the selected directory with hidden dirs
fzf-cd-hidden-widget() {
  local cmd="${FZF_HIDDEN_DIR_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CD_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N    fzf-cd-hidden-widget
bindkey '\eD' fzf-cd-hidden-widget
alias D='fzf-cd-hidden-widget'

# ALT-H - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '\eh' fzf-history-widget
alias h='fzf-history-widget'

# -------------------------------------------------------------------------
#                       CUSTOM
# -------------------------------------------------------------------------
# ALT-Q - Kill process
fzf_killps() { 
	zle -I; 
	ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -${1:-9}; 
} 
zle -N fzf_killps;
bindkey '\eq' fzf_killps

#ALT-w apps list 
fzf-dmenu() { 
    # note: xdg-open has a bug with .desktop files, so we cant use that shit
    selected="$(ls /usr/share/applications | fzf -e)"
    nohup `grep '^Exec' "/usr/share/applications/$selected" | tail -1 | sed 's/^Exec=//' | sed 's/%.//'` >/dev/null 2>&1&
}
zle -N fzf-dmenu;
bindkey '\ew' fzf-dmenu

# Edit line in vim with ctrl-v 
autoload edit-command-line; zle -N edit-command-line
bindkey '\ev' edit-command-line

# open 
# support swallow with devour 
# Modified version where you can press
#   - CTRL-O to open with `open` command, edit to swallow
#   - CTRL-E or Enter key to open with the $EDITOR
fzf_open() {
	zle -I;
	FZF_CMD="$FZF_FILE_COMMAND | fzf $FZF_DEFAULT_OPTS $FZF_FILE_OPTS --query="$1" --exit-0 --expect=alt-o,ctrl-e --prompt='open: alt-o→open;else→edit >'"
	IFS=$'\n' out=("$(eval "$FZF_CMD" )")
	key=$(head -1 <<< "$out")
	file=$(head -2 <<< "$out" | tail -1)
	if [ -n "$file" ]; then
		[ "$key" = alt-o ] && devour xdg-open "$file" || ${EDITOR:-vim} "$file"
	fi
}
zle     -N   fzf_open;
bindkey '\ee' fzf_open
alias E='fzf_open'

fzf_open_hidden() {
	zle -I;
	FZF_CMD="$FZF_HIDDEN_FILE_COMMAND | fzf $FZF_DEFAULT_OPTS $FZF_FILE_OPTS --query="$1" --exit-0 --expect=alt-o,ctrl-e --prompt='open hidden: alt-o→open;else→edit >'"
	IFS=$'\n' out=("$(eval "$FZF_CMD" )")
	key=$(head -1 <<< "$out")
	file=$(head -2 <<< "$out" | tail -1)
	if [ -n "$file" ]; then
		[ "$key" = alt-o ] && devour xdg-open "$file" || ${EDITOR:-vim} "$file"
	fi
}
zle     -N   fzf_open_hidden;
bindkey '\eE' fzf_open_hidden
alias E='fzf_open_hidden'

fzf_fasd_open() {
	zle -I;
 FZF_CMD="fzf $FZF_DEFAULT_OPTS $FZF_FILE_OPTS --query="$1" --exit-0 --expect=alt-o,ctrl-e --prompt='fasd: alt-o→open;else→edit >'"
  IFS=$'\n' out=("$(eval "fasd -Rfl | $FZF_CMD" )")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = alt-o ] && devour xdg-open "$file" || ${EDITOR:-vim} "$file"
  fi
}
zle     -N   fzf_fasd_open
bindkey '\eo' fzf_fasd_open
alias o='fzf_fasd_open'

fzf_fasd_cd() {
	zle -I;
  IFS=$'\n' dir=("$(fasd -Rdl | fzf --query="$1" --exit-0 )")
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N   fzf_fasd_cd;
bindkey '\ej' fzf_fasd_cd

alias j='fzf_fasd_cd'

FZF_ALIAS_OPTS=${FZF_ALIAS_OPTS:-"--preview-window up:3:hidden:wrap"}

function fzf_alias() {
    local selection
    # use sed with column to work around MacOS/BSD column not having a -l option
    if selection=$(alias |
                       sed 's/=/\t/' |
                       column -s '	' -t |
                       FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_ALIAS_OPTS" fzf --preview "echo {2..}" --query="$BUFFER" |
                       awk '{ print $1 }'); then
        BUFFER=$selection
    fi
    zle redisplay
}

zle -N fzf_alias
bindkey -M emacs '\ea' fzf_alias
bindkey -M vicmd '\ea' fzf_alias
bindkey -M viins '\ea' fzf_alias

fzf_mark() {
	zle -I;
  local ret=fzm
  zle reset-prompt
  return $ret
}
zle     -N   fzf_mark
bindkey '\em' fzm
alias m='fzm'

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
