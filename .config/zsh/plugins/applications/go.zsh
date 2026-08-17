#!/usr/bin/env zsh

(($+commands[go])) || return

export GOPATH="${GOPATH:-${HOME}/go}"
export PATH="${GOPATH}/bin:${PATH}"
