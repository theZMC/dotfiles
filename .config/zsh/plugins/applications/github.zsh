#!/usr/bin/env zsh

if (($+commands[gh])); then
  _gh_copilot_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gh-copilot-aliases.zsh"
  if [[ ! -e $_gh_copilot_cache || ${commands[gh]} -nt $_gh_copilot_cache ]]; then
    mkdir -p ${_gh_copilot_cache:h}
    gh copilot alias -- zsh >|$_gh_copilot_cache 2>/dev/null
  fi
  source $_gh_copilot_cache
  unset _gh_copilot_cache

  # GITHUB_TOKEN is keyring-backed, so don't cache it to disk; defer the fetch to
  # keep the keyring call off the startup critical path (var is briefly unset).
  if whence -w zsh-defer >/dev/null 2>&1; then
    zsh-defer -c 'export GITHUB_TOKEN=$(gh auth token 2>/dev/null)'
  else
    export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
  fi
fi
