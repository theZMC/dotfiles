#!/usr/bin/env zsh

if (($+commands[zoxide])); then
  eval "$(zoxide init --cmd cd zsh)"
  export _ZO_DOCTOR=0
fi
