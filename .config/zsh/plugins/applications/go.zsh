if (( $+commands[go] )); then
  export GOPATH="${GOPATH:-${HOME}/go}"
  export PATH="${GOPATH}/bin:${PATH}"
fi
