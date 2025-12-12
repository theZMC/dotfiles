if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export CODE_HOME="${XDG_DATA_HOME:-${HOME}/Sync/code}"

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
  source "$plugin"
done

test -f ~/.p10k.zsh \
  && source ~/.p10k.zsh
test -f ~/.zshrc.local \
  && source ~/.zshrc.local

unsetopt BEEP
