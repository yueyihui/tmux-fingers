#!/usr/bin/env bash

eval "$(tmux show-env -g -s | grep ^FINGERS)"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $CURRENT_DIR/hints.sh
source $CURRENT_DIR/utils.sh
source $CURRENT_DIR/help.sh
source $CURRENT_DIR/debug.sh
#source $CURRENT_DIR/keys.sh

current_pane_id=$1
fingers_pane_id=$2
last_pane_id=$3
fingers_window_id=$4
pane_input_temp=$5
original_rename_setting=$6

function enable_fingers_mode () {
  tmux set-window-option key-table fingers
  tmux switch-client -T fingers
}

function hide_cursor() {
  echo -n "$(tput civis)"
}

function copy_result() {
  local result="$1"
  local hint="$2"

  tmux set-buffer "$result"

  if [[ $HAS_TMUX_YANK = 1 ]]; then
    tmux run-shell -b "printf \"$result\" | $EXEC_PREFIX $tmux_yank_copy_command"
  fi
}

function run_fingers_copy_command() {
  local result="$1"
  local hint="$2"

  is_uppercase=$(echo "$input" | grep -E '^[a-z]+$' &> /dev/null; echo $?)

  if [[ $is_uppercase == "1" ]] && [ ! -z "$FINGERS_COPY_COMMAND_UPPERCASE" ]; then
    command_to_run="$FINGERS_COPY_COMMAND_UPPERCASE"
  elif [ ! -z "$FINGERS_COPY_COMMAND" ]; then
    command_to_run="$FINGERS_COPY_COMMAND"
  fi

  if [[ ! -z "$command_to_run" ]]; then
    tmux run-shell -b "export IS_UPPERCASE=\"$is_uppercase\" HINT=\"$hint\" && printf \"$result\" | $EXEC_PREFIX $command_to_run"
  fi
}

function revert_to_original_pane() {
  tmux swap-pane -s "$current_pane_id" -t "$fingers_pane_id"
  tmux set-window-option automatic-rename "$original_rename_setting"

  if [[ ! -z "$last_pane_id" ]]; then
    tmux select-pane -t "$last_pane_id"
    tmux select-pane -t "$current_pane_id"
  fi

  [[ $pane_was_zoomed == "1" ]] && zoom_pane "$current_pane_id"

}

# TODO capture settings ( pane was zoomed, rename setting, bla bla ) in assoc-array and restore them on exit
# TODO assoc-array with state
compact_state=$FINGERS_COMPACT_HINTS

declare -A state
declare -A prev_state

function toggle_state() {
  local key="$1"
  local value="${state[$key]}"

  ((value ^= 1))

  state[$key]="$value"
}

function track_state() {
  for key in "${!state[@]}"; do
    prev_state[$key]="${state[$key]}"
  done
}

function did_state_change() {
  local key="$1"
  local transition="$2"
  local did_change='0'

  if [[ "${prev_state[$key]}" != "${state[$key]}" ]]; then
    did_change='1'
  fi

  if [[ -z "$transition" ]]; then
    echo "$did_change"
    return
  fi

  if [[ "${prev_state[$key]} => ${state[$key]}" == "$transition" ]]; then
    echo '1'
  else
    echo '0'
  fi
}

function accept_hint() {
  local statement="$1"
  IFS=: read -r _command hint action <<<$(echo "$statement")

  state[input]="${state[input]}$hint"
  state[action]="$action"
}

function handle_exit() {
  log "[fingers-mode] handling exit"
  revert_to_original_pane
  # TODO run action
  rm -rf "$pane_input_temp" "$pane_output_temp" "$match_lookup_table"

  # TODO actually switch to previous mode, or remove auto-switching from plugin init

  tmux set-window-option key-table root
  tmux switch-client -Troot
  cat /dev/null > /tmp/fingers-command-queue
  log "[fingers-mode] exited"
  tmux kill-window -t "$fingers_window_id"
}

function read_statement() {
  statement=''

  while read -rsn1 char; do
    if [[ "$char" == "" ]]; then
      break
    fi

    statement="$statement$char"
  done < /dev/tty

  export statement
}

state[show_help]=0
state[compact_mode]="$FINGERS_COMPACT_HINTS"
state[input]=''
state[action]=''

trap "handle_exit" EXIT

hide_cursor
show_hints_and_swap "$current_pane_id" "$fingers_pane_id" "$compact_state"
enable_fingers_mode

touch /tmp/fingers-command-queue
cat /dev/null > /tmp/fingers-command-queue

tail -f /tmp/fingers-command-queue | while read -r -s statement
do
  tmux display-message "$statement"

  track_state

  case $statement in
    # TODO maybe different key tables for fingers-help and show/hide help statements
    toggle-help)
      toggle_state "show_help"
      ;;
    toggle-compact-mode)
      toggle_state "compact_mode"
      ;;
    hint:*)
      accept_hint "$statement"
    ;;
    continue)
      continue
    ;;
    exit)
      exit 0
    ;;
  esac

  if [[ $(did_state_change "show_help" "0 => 1") == 1 ]]; then
    show_help "$fingers_pane_id"
  fi

  if [[ $(did_state_change "show_help" "1 => 0") == 1 ]]; then
    show_hints "$fingers_pane_id" "${state[compact_mode]}"
  fi

  if [[ $(did_state_change "compact_mode") == 1 ]]; then
    show_hints "$fingers_pane_id" "${state[compact_mode]}"
  fi

  input="${state[input]}"

  result=$(lookup_match "$input")

  if [[ -n $result ]]; then
    tmux display-message "copying result $result ( action: ${state[action]} )"
    copy_result "$result" "$input"
    exit 0
  fi
done
