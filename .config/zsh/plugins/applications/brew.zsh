if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
  if [[ -d /opt/homebrew/opt/grep/libexec/gnubin ]]; then
    PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
  fi
  export HOMEBREW_NO_ENV_HINTS=1
  export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"
fi
