#!/usr/bin/env bash

focus_event="$1"
target_pane_id="$2"

current_pane_id=$(tmux list-panes -F "#{pane_id}:#{?pane_active,active,nope}" | grep active | cut -d: -f1 | sed 's/^\s*//g')

echo "focus-$focus_event-event ( target: $target_pane_id current: $current_pane_id )" >> /tmp/wtf.log

if [[ "$current_pane_id" == "$target_pane_id" && "$focus_event" == "in" ]]; then
  tmux set-window-option key-table fingers
  tmux switch-client -T fingers
  echo "fingers focus-in" >> /tmp/wtf.log
fi

if [[ "$current_pane_id" != "$target_pane_id" && "$focus_event" == "out" ]]; then
  # TODO restore to previous state not defaults? not sure
  tmux set-window-option key-table root
  tmux switch-client -Troot
  echo "fingers focus-out" >> /tmp/wtf.log
fi

exit 0
