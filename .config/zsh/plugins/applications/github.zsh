#!/usr/bin/env zsh

if (($+commands[gh])); then
  # gh copilot aliases (ghcs/ghce): cache the generated functions and regenerate
  # only when the gh binary changes. The output isn't secret, so disk-caching it
  # is safe and keeps the ~12ms fork off every startup.
  _gh_copilot_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gh-copilot-aliases.zsh"
  if [[ ! -e $_gh_copilot_cache || ${commands[gh]} -nt $_gh_copilot_cache ]]; then
    mkdir -p ${_gh_copilot_cache:h}
    gh copilot alias -- zsh >|$_gh_copilot_cache 2>/dev/null
  fi
  source $_gh_copilot_cache
  unset _gh_copilot_cache

  # GITHUB_TOKEN is keyring-backed (not stored in plaintext), so caching it to
  # disk would expose a credential the keyring currently protects. Instead, fetch
  # it just after the first prompt via zsh-defer so the keyring call stays off the
  # startup critical path. Trade-off: the var is briefly unset right after launch.
  if whence -w zsh-defer >/dev/null 2>&1; then
    zsh-defer -c 'export GITHUB_TOKEN=$(gh auth token 2>/dev/null)'
  else
    export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
  fi
fi
