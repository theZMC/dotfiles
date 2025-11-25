if (( $+commands[brew] )); then
  source <(brew shellenv)
  export HOMEBREW_NO_ENV_HINTS=1
fi
