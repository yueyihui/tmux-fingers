#!/usr/bin/env bash

tmux wait-for -L fingers-input

echo "$1" >> /tmp/fingers-command-queue

tmux wait-for -U fingers-input

exit 0
