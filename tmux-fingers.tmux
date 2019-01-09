#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux run -b "bash --norc --noprofile $CURRENT_DIR/scripts/config.sh"
tmux run -b "$CURRENT_DIR/scripts/setup-fingers-mode-bindings.sh"

DEFAULT_FINGERS_KEY="F"
FINGERS_KEY=$(tmux show-option -gqv @fingers-key)
FINGERS_KEY=${FINGERS_KEY:-$DEFAULT_FINGERS_KEY}

tmux bind-key $FINGERS_KEY run-shell "$CURRENT_DIR/scripts/tmux-fingers.sh"

mkdir -p $CURRENT_DIR/.cache
