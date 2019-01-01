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

  #TODO dont let statements get recorded in bash history
  tmux bind-key -Tfingers "$key" send-keys "$command" \\\; send-keys Enter \\\; switch-client -Tfingers
}

# TODO this might be slowing down startup, maybe run in background

for char in {a..z}
do

  if [[ "$char" == "c" ]]; then
    continue
  fi


  # TODO might need to unbind prefix :O
  # TODO might need some locking mechanism

  fingers_bind "$char" "hint:$char:main"
  fingers_bind "$(echo "$char" | tr '[:lower:]' '[:upper:]')" "hint:$char:shift"
  fingers_bind "C-$char" "hint:$char:ctrl"
  fingers_bind "M-$char" "hint:$char:alt"
done

fingers_bind "C-c" "exit"
fingers_bind "Escape" "exit"
fingers_bind "q" "exit"

fingers_bind "?" "toggle-help"
fingers_bind "Space" "toggle-compact-mode"

# TODO bind escape to exit
