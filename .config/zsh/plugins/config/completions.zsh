#!/usr/bin/env zsh
#
# Lazily generate each tool's completion on first Tab and cache it to disk.
# Must be sourced after compinit (it relies on compdef).

# cmd => generator; empty value means the conventional `<cmd> completion zsh`.
typeset -gA ZSH_LAZY_COMPLETIONS=(
  crush ''
  flux ''
  gh 'gh completion -s zsh'
  glab 'glab completion -s zsh'
  istioctl ''
  uds ''
  zarf ''
)

ZSH_COMPL_CACHE="${ZSH_COMPL_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions}"

# Generic name dodges cobra's `_<cmd>` self-run guard: when we source the cached
# script, funcstack[1] is _lazy_completion_loader, so the guard never fires.
_lazy_completion_loader() {
  emulate -L zsh
  local cmd=${words[1]:t}
  local gen=${ZSH_LAZY_COMPLETIONS[$cmd]:-}
  [[ -n $gen ]] || gen="$cmd completion zsh"
  local cache="${ZSH_COMPL_CACHE}/${cmd}.zsh"

  if [[ ! -s $cache || ${commands[$cmd]} -nt $cache ]]; then
    mkdir -p ${cache:h}
    eval "$gen" >|$cache 2>/dev/null
  fi
  source $cache

  if (($+functions[_$cmd])); then
    compdef "_$cmd" "$cmd"
    _$cmd "$@" # the real completion is now registered; serve this first request
  else
    compdef -d "$cmd" # generation failed or named its fn differently; stop retrying
    _default
  fi
}

() {
  local cmd
  for cmd in ${(k)ZSH_LAZY_COMPLETIONS}; do
    (($+commands[$cmd])) || continue
    compdef _lazy_completion_loader "$cmd"
  done
}
