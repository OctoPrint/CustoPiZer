#!/bin/bash

set -x
set -e

export LC_ALL=C


USERNAME=pioreactor
PIO_DIR=/home/$USERNAME/.pioreactor
SSH_DIR=/home/$USERNAME/.ssh
DB_LOC=/home/$USERNAME/.pioreactor/storage/pioreactor.sqlite

sudo -u $USERNAME rm -rf $SSH_DIR # remove if already exists.

sudo -u $USERNAME mkdir -p $SSH_DIR
sudo -u $USERNAME touch $SSH_DIR/authorized_keys
sudo -u $USERNAME touch $SSH_DIR/known_hosts

sudo -u $USERNAME ssh-keygen -q -t rsa -N '' -f $SSH_DIR/id_rsa
sudo -u $USERNAME cat $SSH_DIR/id_rsa.pub > $SSH_DIR/authorized_keys
sudo -u $USERNAME ssh-keyscan $(hostname).local >> $SSH_DIR/known_hosts
sudo -u $USERNAME echo "StrictHostKeyChecking accept-new" >> $SSH_DIR/config
sudo -u $USERNAME echo "CheckHostIP no" >> $SSH_DIR/config


crudini --set $PIO_DIR/config.ini cluster.topology leader_hostname "$(hostname)"
crudini --set $PIO_DIR/config.ini cluster.topology leader_address "$(hostname)".local

sqlite3 $DB_LOC "INSERT OR IGNORE INTO experiments (created_at, experiment, description) VALUES (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'NOW'), 'Demo experiment', 'This is a demo experiment. Feel free to click around. When you are ready, click the [New experiment] above.');"
mosquitto_pub -t "pioreactor/latest_experiment/experiment" -m "Demo experiment" -r -q 1
mosquitto_pub -t "pioreactor/latest_experiment/created_at" -m "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" -r -q 1
