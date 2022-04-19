#!/bin/bash

set -x
set -e

export LC_ALL=C

USERNAME=pioreactor
SSH_DIR=/home/$USERNAME/.ssh

sudo -u $USERNAME rm -rf $SSH_DIR # remove if already exists.

sudo -u $USERNAME mkdir -p $SSH_DIR
sudo -u $USERNAME touch $SSH_DIR/authorized_keys
sudo -u $USERNAME touch $SSH_DIR/known_hosts

sudo -u $USERNAME ssh-keygen -q -t rsa -N '' -f $SSH_DIR/id_rsa
sudo -u $USERNAME cat $SSH_DIR/id_rsa.pub > $SSH_DIR/authorized_keys
