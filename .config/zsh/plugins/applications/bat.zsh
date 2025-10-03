if (( $+commands[bat] || $+commands[batcat] )); then
  export BAT_PAGER="less -RFX" 
  if ! (( $+commands[bat] )); then
    alias bat=batcat
  fi
  alias cat=bat
fi
