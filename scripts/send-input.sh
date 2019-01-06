#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $CURRENT_DIR/debug.sh

tmux wait-for -L fingers-input

log "[input] sending command '$1'"
tmux send-keys "$1"

log "[input] sending Enter"
tmux send-keys Enter

tmux wait-for -U fingers-input

exit 0
