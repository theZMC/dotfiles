#!/usr/bin/env zsh

() {
  (($+commands[gpg])) || return
  local pubkey="${HOME}/.gnupg/pubkey.asc"
  local trustfile="${HOME}/.gnupg/ownertrust.txt"
  local marker="${XDG_STATE_HOME:-${HOME}/.local/state}/gpg-pubkey-imported"
  [[ -f "$pubkey" ]] || return
  [[ -f "$marker" && "$marker" -nt "$pubkey" ]] && return

  gpg --import "$pubkey" 2>/dev/null
  [[ -f "$trustfile" ]] && gpg --import-ownertrust "$trustfile" 2>/dev/null
  mkdir -p "${marker:h}"
  touch "$marker"
}
