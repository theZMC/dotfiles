can_start=true
if ! (( $+commands[git] )); then
  echo "git must be installed for this zsh config to work"
  can_start=false
fi

if ! (( $+commands[wget] || $+commands[curl] )); then
  echo "either wget or curl must be installed for this zsh config to work"
  can_start=false
fi

if ! ${can_start}; then
  return
fi

test -d ~/.local/bin \
  && export PATH="${HOME}/.local/bin:${PATH}"

source "${XDG_CONFIG_HOME:-${HOME}/.config}"/zsh/plugins/antidote/provision.zsh

for plugin in "${XDG_CONFIG_HOME:-${HOME}/.config}"/zsh/plugins/{applications,config}/*.zsh; do
  if [[ -L "$plugin" ]]; then
    if [[ ! -e "$plugin" ]]; then
      unlink "$plugin" # prune broken symlinks to gracefully handle plugin removals
      continue
    fi
  fi

  source "$plugin"
done

source <(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/config.yaml")

test -f ~/.zshrc.local \
  && source ~/.zshrc.local

unsetopt BEEP
