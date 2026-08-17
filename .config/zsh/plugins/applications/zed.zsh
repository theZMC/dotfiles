#!/usr/bin/env zsh

[[ -n $ZED_TERM ]] || return

# Zed passes the launching shell's env to its terminals, so $TMUX leaks in even
# though tmux never runs here (OMZ tmux skips autostart under ZED_TERM). fzf's
# --tmux keys off $TMUX and would pop up in the outer session instead.
unset TMUX TMUX_PANE
