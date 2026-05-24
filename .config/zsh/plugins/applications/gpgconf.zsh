#!/usr/bin/env zsh

(($+commands[gpgconf])) || return

export GPG_TTY="$(tty)"

if [[ -n "$SSH_CONNECTION" ]]; then
  case "$SSH_AUTH_SOCK" in
    /tmp/ssh-* | */gnupg/S.gpg-agent.ssh) return ;;
  esac
fi

local sock="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"
if [[ -S "$sock" ]]; then
  unset SSH_AGENT_PID
  export SSH_AUTH_SOCK="$sock"
fi

autoload -Uz add-zsh-hook
_gpg_agent_update_tty() { gpg-connect-agent updatestartuptty /bye &>/dev/null; }
add-zsh-hook preexec _gpg_agent_update_tty
