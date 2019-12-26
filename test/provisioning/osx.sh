#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

brew install bash gawk

# TODO add fihsman user

sudo mkdir -p /opt/vagrant
sudo ln -s "$PWD" /opt/vagrant/shared

$CURRENT_DIR/../install-tmux-versions.sh
