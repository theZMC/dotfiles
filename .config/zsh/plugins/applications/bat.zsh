if (( $+commands[bat] )); then
  export BAT_PAGER="less -RFX" 
  alias cat=bat
fi
