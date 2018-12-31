#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux run -b "bash --norc --noprofile $CURRENT_DIR/scripts/config.sh"

DEFAULT_FINGERS_KEY="F"
FINGERS_KEY=$(tmux show-option -gqv @fingers-key)
FINGERS_KEY=${FINGERS_KEY:-$DEFAULT_FINGERS_KEY}

tmux bind-key $FINGERS_KEY run-shell "$CURRENT_DIR/scripts/tmux-fingers.sh"

function fingers_bind() {
  local key="$1"
  local command="$2"

  tmux bind-key -Tfingers "$key" send-keys "$command" \\\; send-keys Enter \\\; switch-client -Tfingers
}

for char in {a..z}
do

  # TODO might need to unbind prefix :O

  fingers_bind "$char" "hint:$char:primary"
  fingers_bind "C-$char" "hint:$char:secondary"
  fingers_bind "M-$char" "hint:$char:tertiary"
done

fingers_bind "?" "toggle-help"
fingers_bind "space" "toggle-compact-mode"

# TODO bind escape to exit
