#!/usr/bin/env zsh

(($+commands[bat] || $+commands[batcat])) || return

export BAT_PAGER="less -RFX"
if ! (($+commands[bat])); then
  alias bat=batcat
fi
alias cat=bat
