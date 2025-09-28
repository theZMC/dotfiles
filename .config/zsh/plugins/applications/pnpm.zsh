if (( $+commands[pnpm] )); then
  export PNPM_HOME="${PNPM_HOME:-${HOME}/.local/share/pnpm}"
  export PATH="${PNPM_HOME}:${PATH}"
fi
