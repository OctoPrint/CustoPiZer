#!/bin/bash

set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


apt-get update
apt-get install -y git
apt-get install -y python3-pip
pip3 install pip -U  # update to latest pip
pip3 config set global.disable-pip-version-check true
pip3 config set global.root-user-action "ignore"
pip3 install wheel
