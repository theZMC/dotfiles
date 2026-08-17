#!/usr/bin/env zsh

(($+commands[rustup])) || return

export PATH="${HOME}/.cargo/bin:${PATH}"
