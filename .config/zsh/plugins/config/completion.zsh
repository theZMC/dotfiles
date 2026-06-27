#!/usr/bin/env zsh

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Cached compinit: the expensive part is the security audit (compaudit) plus
# rebuilding and writing the dump (compdump). Do that at most once per day; on
# every other startup trust the existing dump and skip straight to loading it
# with -C. The dump lives at a single canonical XDG path so there is exactly one.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"
if [[ -n "${_zcompdump}"(#qNmh+24) ]]; then
  compinit -d "$_zcompdump" # >24h old (or missing): full audit + rebuild
else
  compinit -C -d "$_zcompdump" # fresh: trust the dump, skip the audit
fi

# Compile the dump to bytecode so subsequent shells mmap it instead of reparsing.
if [[ -s "$_zcompdump" && (! -s "${_zcompdump}.zwc" || "$_zcompdump" -nt "${_zcompdump}.zwc") ]]; then
  zcompile -R -- "${_zcompdump}.zwc" "$_zcompdump" 2>/dev/null
fi
unset _zcompdump

autoload -U +X bashcompinit
bashcompinit
