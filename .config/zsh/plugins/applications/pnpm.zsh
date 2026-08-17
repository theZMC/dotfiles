#!/usr/bin/env zsh

(($+commands[pnpm])) || return

export PNPM_HOME="${PNPM_HOME:-${HOME}/.local/share/pnpm}"
export PATH="${PNPM_HOME}:${PATH}"
