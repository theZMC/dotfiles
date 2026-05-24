#!/usr/bin/env zsh

if (($+commands[zoxide])); then
  eval "$(zoxide init --cmd cd zsh)"
fi
