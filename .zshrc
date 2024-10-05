function have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

can_start=true
have_cmd git || (echo "git must be installed for this zsh config to work" && can_start=false)
have_cmd wget || have_cmd curl || (echo "either wget or curl must be installed for this zsh config to work" && can_start=false)

if ! $can_start; then
  return
fi

autoload -Uz compinit && compinit
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

test -f /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zsh_plugins="$(cat <<EOF

zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
Aloxaf/fzf-tab
romkatv/powerlevel10k
zdharma-continuum/fast-syntax-highlighting kind:defer

getantidote/use-omz
ohmyzsh/ohmyzsh path:lib
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/aws
ohmyzsh/ohmyzsh path:plugins/brew
ohmyzsh/ohmyzsh path:plugins/command-not-found
ohmyzsh/ohmyzsh path:plugins/kubectl
ohmyzsh/ohmyzsh path:plugins/kubectx
ohmyzsh/ohmyzsh path:plugins/mvn
ohmyzsh/ohmyzsh path:plugins/dotnet
ohmyzsh/ohmyzsh path:plugins/terraform
ohmyzsh/ohmyzsh path:plugins/github
ohmyzsh/ohmyzsh path:plugins/golang
ohmyzsh/ohmyzsh path:plugins/vi-mode

EOF
)"

have_cmd tmux && export ZSH_TMUX_AUTOSTART=true && zsh_plugins="${zsh_plugins}\nohmyzsh/ohmyzsh path:plugins/tmux"

if have_cmd gpgconf; then
  export GPG_TTY="$(tty)" && \
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && \
  gpgconf --launch gpg-agent && \
  gpg-connect-agent updatestartuptty /bye > /dev/null
fi

zsh_config_root="${XDG_CONFIG_HOME:-${HOME}}/.config/zsh"
test -d "$zsh_config_root" || mkdir -p "$zsh_config_root"
antidote_dir="$zsh_config_root/antidote"

test -d "$antidote_dir" || git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_dir"
source "$antidote_dir/antidote.zsh"
fpath=("$antidote_dir/functions" $fpath)
autoload -Uz antidote

zsh_plugins_root="$zsh_config_root/plugins"
test -f "$zsh_plugins_root.txt" || touch "$zsh_plugins_root.txt"
test -f "$zsh_plugins_root.zsh" || touch "$zsh_plugins_root.zsh"
if ! diff <(echo "$zsh_plugins") "$zsh_plugins_root.txt" >/dev/null 2>&1; then
  echo "$zsh_plugins" > "$zsh_plugins_root.txt"
  antidote bundle <"$zsh_plugins_root.txt" >|"$zsh_plugins_root.zsh"
fi
source "$zsh_plugins_root.zsh"

test -f ~/.p10k.zsh && source ~/.p10k.zsh

FAST_HIGHLIGHT[git-cmsg-len]=80

have_cmd tofu && alias terraform=tofu
have_cmd nvim && export EDITOR=nvim && export VISUAL=nvim && alias vi=vim && alias vim=nvim
have_cmd go && export GOPATH="${GOPATH:-${HOME}/go}" && export PATH="$GOPATH/bin:$PATH"
have_cmd rustup && export PATH="$HOME/.cargo/bin:$PATH"
have_cmd pyenv && source <(pyenv init --path)
have_cmd fzf && source <(fzf --zsh)
have_cmd zoxide && source <(zoxide init --cmd cd zsh)

HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':omz:lib:theme-and-appearance' gnu-ls yes
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
