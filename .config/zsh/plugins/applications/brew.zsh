if (( $+commands[brew] )); then
  source <(brew shellenv)
  if [[ -d /opt/homebrew/opt/grep/libexec/gnubin ]]; then
    PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
  fi
  export HOMEBREW_NO_ENV_HINTS=1
fi
