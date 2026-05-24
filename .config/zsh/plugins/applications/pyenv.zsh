#!/usr/bin/env zsh

if (($+commands[pyenv])); then
  eval "$(pyenv init --path)"
fi
