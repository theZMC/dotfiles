#!/usr/bin/env zsh

(($+commands[pyenv])) || return

eval "$(pyenv init --path)"
