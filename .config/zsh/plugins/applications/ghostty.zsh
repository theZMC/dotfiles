if (( ! $+commands[ghostty] )); then
  return
fi

function ghostty-run {
  (nohup ghostty -e "$@" </dev/null >/dev/null 2>&1 &)
}
