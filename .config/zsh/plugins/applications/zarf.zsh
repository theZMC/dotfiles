#!/usr/bin/env zsh

if (($+commands[zarf])); then
  eval "$(zarf completion zsh)"
fi
