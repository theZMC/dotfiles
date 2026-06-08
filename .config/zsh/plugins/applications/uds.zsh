#!/usr/bin/env zsh

if (($+commands[uds])); then
  eval "$(uds completion zsh)"
fi
