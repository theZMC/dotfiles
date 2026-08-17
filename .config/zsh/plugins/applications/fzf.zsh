#!/usr/bin/env zsh

(($+commands[fzf])) || return

# `fzf --zsh` needs fzf >= 0.48; capture it first so a failure is detectable
# (eval of an empty string succeeds), then fall back to the distro examples.
if _fzf_init="$(fzf --zsh 2>/dev/null)"; then
  eval "$_fzf_init"
elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
else
  echo "fzf: no key bindings available (fzf --zsh unsupported, no examples dir)" >&2
fi
unset _fzf_init

# Assign, don't append: nested shells inherit the exported value and would
# otherwise duplicate these flags on every startup.
export FZF_DEFAULT_OPTS="\
  --highlight-line \
  --info=inline-right \
  --ansi \
  --tmux 90% \
  --no-height \
  --no-reverse \
  --border=none \
  --style=full \
  --color=bg+:#1E222A \
  --color=bg:#1A1D23 \
  --color=border:#3A3E47 \
  --color=fg:#ADB0BB \
  --color=gutter:#1A1D23 \
  --color=header:#50A4E9 \
  --color=hl+:#5EB7FF \
  --color=hl:#5EB7FF \
  --color=info:#3A3E47 \
  --color=marker:#5EB7FF \
  --color=pointer:#5EB7FF \
  --color=prompt:#5EB7FF \
  --color=query:#ADB0BB:regular \
  --color=scrollbar:#3A3E47 \
  --color=separator:#3A3E47 \
  --color=spinner:#5EB7FF \
"

if (($+commands[preview])); then
  export FZF_CTRL_T_OPTS="${FZF_DEFAULT_OPTS} --preview 'preview {}' --preview-window='right:60%'"
fi

if (($+commands[rg])); then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!{.git,node_modules}/*"'
fi

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
