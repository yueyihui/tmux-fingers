#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux run -b "bash --norc --noprofile $CURRENT_DIR/scripts/config.sh"

DEFAULT_FINGERS_KEY="F"
FINGERS_KEY=$(tmux show-option -gqv @fingers-key)
FINGERS_KEY=${FINGERS_KEY:-$DEFAULT_FINGERS_KEY}

tmux bind-key $FINGERS_KEY run-shell "$CURRENT_DIR/scripts/tmux-fingers.sh"

for char in {a..z}
do
  action="display-message"
  action="send-keys"

  # TODO might need to unbind prefix :O

  tmux bind-key -Tfingers "$char" "$action" "$char" \\\; switch-client -Tfingers
  tmux bind-key -Tfingers "C-$char" "$action" "$(echo $char | tr '[:lower:]' '[:upper:]')" \\\; switch-client -Tfingers
  tmux bind-key -Tfingers "M-$char" "$action" "$(echo $char | tr '[:lower:]' '[:upper:]')" \\\; switch-client -Tfingers
done
