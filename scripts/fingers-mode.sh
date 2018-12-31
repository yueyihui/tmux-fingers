#!/usr/bin/env bash

eval "$(tmux show-env -g -s | grep ^FINGERS)"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $CURRENT_DIR/hints.sh
source $CURRENT_DIR/utils.sh
source $CURRENT_DIR/help.sh

#HAS_TMUX_YANK=$([ "$(tmux list-keys | grep -c tmux-yank)" == "0" ]; echo $?)
#tmux_yank_copy_command=$(tmux_list_vi_copy_keys | grep -E "(vi-copy|copy-mode-vi) *y" | sed -E 's/.*copy-pipe(-and-cancel)? *"(.*)".*/\2/g')

current_pane_id=$1
fingers_pane_id=$2
#last_pane_id=$3
#fingers_window_id=$4
#pane_input_temp=$5
#original_rename_setting=$6

function enable_fingers_mode () {
  tmux switch-client -T fingers
}

function hide_cursor() {
  echo -n "$(tput civis)"
}


# TODO capture settings ( pane was zoomed, rename setting, bla bla ) in assoc-array and restore them on exit
# TODO assoc-array with state
compact_state=$FINGERS_COMPACT_HINTS

declare -A state

function toggle_state() {
  local key="$1"
  local value="${state[$key]}"

  ((value ^= 1))

  state[$key]="$value"
}

state[show_help]=0
state[compact_mode]="$FINGERS_COMPACT_HINTS"

hide_cursor
show_hints_and_swap "$current_pane_id" "$fingers_pane_id" "$compact_state"
enable_fingers_mode

while read -rs statement; do
  tmux display-message "$statement"

  case $statement in
    toggle-help)
      toggle_state "show_help"
      ;;
    toggle-compact-mode)
      toggle_state "compact_mode"
      ;;
    hint:*:primary)
      ;;
    hint:*:secondary)
      ;;
    hint:*:tertiary)
      ;;
  esac

done < /dev/tty
