if (( $+commands[npm] )); then
  export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-${HOME}/.npm-global}"
  export PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"
fi
