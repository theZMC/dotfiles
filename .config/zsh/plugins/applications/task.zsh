#!/usr/bin/env zsh

(($+commands["go-task"])) || return

alias task=go-task
