#!/usr/bin/env zsh

if (($+commands[crush])); then
  eval "$(crush completion zsh)"
fi
