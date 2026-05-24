#!/usr/bin/env zsh

if (($+commands[rustup])); then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi
