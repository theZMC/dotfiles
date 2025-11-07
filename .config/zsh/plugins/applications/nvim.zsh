if (( $+commands[nvim] )); then
  export EDITOR=nvim
  export VISUAL=nvim
  export MANPAGER="nvim +Man!"

  alias vi=vim
  alias vim=nvim
  alias vimdiff="nvim -d"
  alias diff=vimdiff

  # Clear the Neovim LSP log file if it exists
  if [[ -f ~/.local/state/nvim/lsp.log ]]; then
    echo '' > ~/.local/state/nvim/lsp.log
  fi
fi
