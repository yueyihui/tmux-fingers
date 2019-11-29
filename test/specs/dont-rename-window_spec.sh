#!/usr/bin/env bash

# fixing https://github.com/Morantron/tmux-fingers/issues/65

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CURRENT_DIR/../tmuxomatic.sh
source $CURRENT_DIR/../helpers.sh

tmuxomatic__begin begin_hook

set -x

begin_with_conf "automatic-rename"
init_pane

tmuxomatic__exec "watch 'echo wat'"

sleep 5
invoke_fingers
tmuxomatic send-keys C-c
sleep 5
tmuxomatic send-keys C-c
sleep 5

tmuxomatic__exec "tmux list-windows -F 'window_name: #{window_name}'"

sleep 15

tmuxomatic__end end_hook

