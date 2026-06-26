#!/usr/bin/env zsh

if (($+commands[gh])); then
  eval "$(gh copilot alias -- zsh 2>/dev/null)"
  export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
fi
