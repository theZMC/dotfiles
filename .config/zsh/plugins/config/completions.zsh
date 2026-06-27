#!/usr/bin/env zsh
#
# Lazily load shell completions. The real completion for a tool is generated on
# the FIRST Tab for that command, cached to disk, then handed off to the tool's
# own completion function for the rest of the session. Generation re-runs only
# when the tool's binary is newer than its cache, so even the first Tab of future
# sessions does no fork until the tool is upgraded.
#
# Migrating a tool here: delete its `eval "$(<tool> completion zsh)"` line from
# wherever it lives and add the command below. Config plugins that ALSO do other
# work (set vars, etc.) keep that work; only the completion line moves here.
#
# Must be sourced AFTER compinit -- it relies on compdef. The application/config
# loop in .zshrc sources config/ after applications/, and this file sorts after
# completion.zsh (which runs compinit), so the ordering holds.

# command => generator. Empty value means the conventional `<cmd> completion zsh`.
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

# Generic loader name dodges cobra's `_<cmd>` self-run guard: when we source the
# generated script, funcstack[1] is _lazy_completion_loader (not _<cmd>), so the
# guard never fires and the completion isn't run twice.
_lazy_completion_loader() {
  emulate -L zsh
  local cmd=${words[1]:t} # :t -> basename, in case completion is invoked via a path
  local gen=${ZSH_LAZY_COMPLETIONS[$cmd]:-}
  [[ -n $gen ]] || gen="$cmd completion zsh"
  local cache="${ZSH_COMPL_CACHE}/${cmd}.zsh"

  # (Re)generate only when the cache is missing/empty or the binary is newer.
  if [[ ! -s $cache || ${commands[$cmd]} -nt $cache ]]; then
    mkdir -p ${cache:h}
    eval "$gen" >|$cache 2>/dev/null
  fi
  source $cache

  if (($+functions[_$cmd])); then
    compdef "_$cmd" "$cmd" # the real completion owns all future Tabs
    _$cmd "$@"             # ...and serve THIS request
  else
    compdef -d "$cmd" # generation failed or unexpected fn name: drop our stub
    _default
  fi
}

# Register the generic stub for every configured tool that is actually installed.
() {
  local cmd
  for cmd in ${(k)ZSH_LAZY_COMPLETIONS}; do
    (($+commands[$cmd])) || continue
    compdef _lazy_completion_loader "$cmd"
  done
}
