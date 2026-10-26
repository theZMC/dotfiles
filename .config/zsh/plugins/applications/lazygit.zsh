#!/usr/bin/env zsh

(($+commands[lazygit])) || return

# Use the Stow-managed config even on platforms with a different default path.
export LG_CONFIG_FILE="${LG_CONFIG_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/lazygit/config.yml}"
