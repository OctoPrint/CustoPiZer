#!/bin/bash

set -x
set -e

export LC_ALL=C

SSH_DIR=/home/pi/.ssh

sudo -u pi rm -rf SSH_DIR # remove if already exists.

sudo -u pi mkdir -p SSH_DIR
sudo -u pi touch SSH_DIR/authorized_keys
sudo -u pi touch SSH_DIR/known_hosts

sudo -u pi ssh-keygen -q -t rsa -N '' -f SSH_DIR/id_rsa
sudo -u pi cat SSH_DIR/id_rsa.pub > SSH_DIR/authorized_keys
