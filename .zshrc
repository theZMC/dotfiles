can_start=true
if ! (( $+commands[git] )); then
  echo "git must be installed for this zsh config to work"
  can_start=false
fi

if ! (( $+commands[wget] || $+commands[curl] )); then
  echo "either wget or curl must be installed for this zsh config to work"
  can_start=false
fi

if ! $can_start; then
  return
fi

if ! [[ $PATH =~ "${HOME}/.local/bin" ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! (( $+commands[mise] )); then
  if (( $+commands[curl] )); then
    curl -fsSL https://mise.run | sh
  else
    wget -qO- https://mise.run | sh
  fi
  rehash # detect mise
  mise install
  rehash # detect everything mise installed
fi

export CODE_HOME="${CODE_HOME:-${HOME}/Sync/code}"

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

test -f ~/.zshrc.local \
  && source ~/.zshrc.local

eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/config.yaml")"

unsetopt BEEP
