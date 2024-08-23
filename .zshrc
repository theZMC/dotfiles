function is_installed() {
  command -v "$1" >/dev/null 2>&1
}

autoload -Uz compinit && compinit

eval "$(/opt/homebrew/bin/brew shellenv)"

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

is_installed nvim && export EDITOR=nvim && export VISUAL=nvim
is_installed go && test -z $GOPATH && export GOPATH="$HOME/go" && export PATH="$GOPATH/bin:$PATH"
is_installed rustup && export PATH="$HOME/.cargo/bin:$PATH"
is_installed pyenv && eval "$(pyenv init --path)"
is_installed tmux && export ZSH_TMUX_AUTOSTART=true

ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)

zsh_config_root="${XDG_CONFIG_HOME:-${HOME}}/.config/zsh"
antidote_dir="$zsh_config_root/antidote"

test -d "$antidote_dir" || git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_dir"
source "$antidote_dir/antidote.zsh"
fpath=("$antidote_dir/functions" $fpath)
autoload -Uz antidote

zsh_plugins="$zsh_config_root/plugins"
test -f "$zsh_plugins.txt" || touch "$zsh_plugins.txt"
if [[ ! "$zsh_plugins.zsh" -nt "$zsh_plugins.txt" ]]; then
  antidote bundle <"$zsh_plugins.txt" >|"$zsh_plugins.zsh"
fi
source $zsh_plugins.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

source <(fzf --zsh)
source <(zoxide init --cmd cd zsh)

alias vi=vim
alias vim=nvim
