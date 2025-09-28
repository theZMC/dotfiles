if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

test -f ~/.p10k.zsh \
  && source ~/.p10k.zsh
test -f ~/.zshrc.local \
  && source ~/.zshrc.local
test -d ~/.local/bin \
  && export PATH="${HOME}/.local/bin:${PATH}"

for plugin in "${XDG_CONFIG_HOME:-${HOME}/.config}"/zsh/plugins/{antidote,applications,config}/*.zsh; do
  source "$plugin"
done

unsetopt BEEP
