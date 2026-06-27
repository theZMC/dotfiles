#!/usr/bin/env zsh

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Run the full audit + dump rebuild at most once a day; otherwise load the
# cached dump with -C. Single canonical path, zcompiled for faster loading.
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
