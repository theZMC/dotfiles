export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

autoload -Uz compinit
compinit

autoload -U +X bashcompinit
bashcompinit
