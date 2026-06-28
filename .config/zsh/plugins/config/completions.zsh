#!/usr/bin/env zsh

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Full audit + dump rebuild at most once a day; otherwise load the cached dump
# with -C. Single canonical path, zcompiled for faster loading.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"
if [[ -n "${_zcompdump}"(#qNmh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi

if [[ -s "$_zcompdump" && (! -s "${_zcompdump}.zwc" || "$_zcompdump" -nt "${_zcompdump}.zwc") ]]; then
  zcompile -R -- "${_zcompdump}.zwc" "$_zcompdump" 2>/dev/null
fi
unset _zcompdump

autoload -U +X bashcompinit
bashcompinit

# cmd => generator (a command whose stdout is a zsh completion script).
# btm/hyperfine/yazi/ya ship no generator, so we cat their static _<cmd> file.
typeset -gA ZSH_LAZY_COMPLETIONS=(
  bat 'bat --completion zsh'
  btm 'cat "$(mise where bottom)"/**/_btm(N) </dev/null'
  bun 'bun completions zsh'
  crane 'crane completion zsh'
  crush 'crush completion zsh'
  deno 'deno completions zsh'
  dive 'dive completion zsh'
  docker 'docker completion zsh'
  fd 'fd --gen-completions zsh'
  flux 'flux completion zsh'
  gh 'gh completion -s zsh'
  glab 'glab completion -s zsh'
  glow 'glow completion zsh'
  golangci-lint 'golangci-lint completion zsh'
  gum 'gum completion zsh'
  helm 'helm completion zsh'
  hyperfine 'cat "$(mise where hyperfine)"/**/_hyperfine(N) </dev/null'
  istioctl 'istioctl completion zsh'
  k3d 'k3d completion zsh'
  k9s 'k9s completion zsh'
  kubectl 'kubectl completion zsh'
  lazygit 'lazygit completion zsh'
  opencode 'opencode completion zsh'
  pnpm 'pnpm completion zsh'
  pulumi 'pulumi gen-completion zsh'
  rg 'rg --generate=complete-zsh'
  ruff 'ruff generate-shell-completion zsh'
  sops 'sops completion zsh'
  taplo 'taplo completions zsh'
  tombi 'tombi completion zsh'
  tpack 'tpack completion zsh'
  tree-sitter 'tree-sitter complete --shell zsh'
  trufflehog 'trufflehog --completion-script-zsh'
  uds 'uds completion zsh'
  usage 'usage --completions zsh'
  uv 'uv generate-shell-completion zsh'
  ya 'cat "$(mise where yazi)"/**/_ya(N) </dev/null'
  yazi 'cat "$(mise where yazi)"/**/_yazi(N) </dev/null'
  yq 'yq completion zsh'
  zarf 'zarf completion zsh'
)

ZSH_COMPL_CACHE="${ZSH_COMPL_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions}"

# Generic name dodges cobra's `_<cmd>` self-run guard: when we source the cached
# script, funcstack[1] is _lazy_completion_loader, so the guard never fires.
_lazy_completion_loader() {
  emulate -L zsh
  local cmd=${words[1]:t}
  local gen=${ZSH_LAZY_COMPLETIONS[$cmd]}
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
