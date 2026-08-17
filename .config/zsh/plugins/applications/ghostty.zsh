#!/usr/bin/env zsh

(($+commands[ghostty])) || return

function ghostty-run {
  (nohup ghostty -e "$@" </dev/null >/dev/null 2>&1 &)
}
