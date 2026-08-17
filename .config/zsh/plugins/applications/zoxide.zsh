#!/usr/bin/env zsh

(($+commands[zoxide])) || return

eval "$(zoxide init --cmd cd zsh)"
export _ZO_DOCTOR=0
