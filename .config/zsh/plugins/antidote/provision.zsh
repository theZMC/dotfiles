unset _style

zsh_plugins=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-completions"
  "Aloxaf/fzf-tab"
  "romkatv/powerlevel10k"
  "zdharma-continuum/fast-syntax-highlighting kind:defer"
  "getantidote/use-omz"
  "ohmyzsh/ohmyzsh path:lib"
  "ohmyzsh/ohmyzsh path:plugins/aws"
  "ohmyzsh/ohmyzsh path:plugins/brew"
  "ohmyzsh/ohmyzsh path:plugins/command-not-found"
  "ohmyzsh/ohmyzsh path:plugins/dotnet"
  "ohmyzsh/ohmyzsh path:plugins/git"
  "ohmyzsh/ohmyzsh path:plugins/github"
  "ohmyzsh/ohmyzsh path:plugins/gnu-utils"
  "ohmyzsh/ohmyzsh path:plugins/golang"
  "ohmyzsh/ohmyzsh path:plugins/gpg-agent"
  "ohmyzsh/ohmyzsh path:plugins/istioctl"
  "ohmyzsh/ohmyzsh path:plugins/kubectl"
  "ohmyzsh/ohmyzsh path:plugins/kubectx"
  "ohmyzsh/ohmyzsh path:plugins/mvn"
  "ohmyzsh/ohmyzsh path:plugins/nvm"
  "ohmyzsh/ohmyzsh path:plugins/terraform"
  "ohmyzsh/ohmyzsh path:plugins/uv"
  "ohmyzsh/ohmyzsh path:plugins/vagrant"
  "ohmyzsh/ohmyzsh path:plugins/vi-mode"
  "ohmyzsh/ohmyzsh path:plugins/web-search"
)

if [ -d /opt/homebrew/bin ]; then
  source <(/opt/homebrew/bin/brew shellenv)
fi

if command -v tmux >/dev/null 2>&1; then
  export ZSH_TMUX_AUTOSTART=true
  zsh_plugins+=("ohmyzsh/ohmyzsh path:plugins/tmux")
fi

zsh_config_root="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh"

if [ ! -d "${zsh_config_root}" ]; then
  mkdir -p "${zsh_config_root}"
fi

antidote_dir="${zsh_config_root}/_antidote"

if [ ! -d "${antidote_dir}" ]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${antidote_dir}"
fi

source "${antidote_dir}/antidote.zsh"
fpath=("${antidote_dir}/functions" ${fpath})
autoload -Uz antidote

zsh_plugins_root="${zsh_config_root}/plugins/antidote/plugins"
if [ ! -f "${zsh_plugins_root}.txt" ]; then
  touch "${zsh_plugins_root}.txt"
fi

if [ ! -f "${zsh_plugins_root}.zsh" ]; then
  touch "${zsh_plugins_root}.zsh"
fi

tmp_plugin_file=$(mktemp)
printf '%s\n' "${zsh_plugins[@]}" > "$tmp_plugin_file"

if ! cmp -s "${tmp_plugin_file}" "${zsh_plugins_root}.txt" || ! test -d ~/.cache/antidote; then
  mv "${tmp_plugin_file}" "${zsh_plugins_root}.txt"
  antidote bundle <"${zsh_plugins_root}.txt" >|"${zsh_plugins_root}.zsh"
fi

source "${zsh_plugins_root}.zsh"

zstyle ':omz:lib:theme-and-appearance' gnu-ls yes
