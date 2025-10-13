if (( $+commands[k9s] )); then
  export K9S_CONFIG_DIR="${K9S_CONFIG_DIR:-${XDG_CONFIG_DIR:-${HOME}/.config}/k9s}"
fi
