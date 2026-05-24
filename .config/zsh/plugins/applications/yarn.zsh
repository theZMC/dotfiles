#!/usr/bin/env zsh

if (($+commands[yarn])); then
  export PATH="${HOME}/.yarn/bin:${PATH}"
fi
