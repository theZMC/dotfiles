#!/usr/bin/env zsh

(($+commands[yarn])) || return

export PATH="${HOME}/.yarn/bin:${PATH}"
