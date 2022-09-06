#!/bin/bash

set -x
set -e

export LC_ALL=C

USERNAME=pioreactor
PIO_DIR=/home/$USERNAME/.pioreactor
SSH_DIR=/home/$USERNAME/.ssh
DB_LOC=$(crudini --get $PIO_DIR/config.ini storage database)

sudo -u $USERNAME rm -rf $SSH_DIR # remove if already exists.


sudo -u $USERNAME mkdir -p $SSH_DIR
sudo -u $USERNAME touch $SSH_DIR/authorized_keys
sudo -u $USERNAME touch $SSH_DIR/known_hosts

sudo -u $USERNAME ssh-keygen -q -t rsa -N '' -f $SSH_DIR/id_rsa
sudo -u $USERNAME cat $SSH_DIR/id_rsa.pub > $SSH_DIR/authorized_keys
sudo -u $USERNAME ssh-keyscan $(hostname).local >> $SSH_DIR/known_hosts
sudo -u $USERNAME echo "StrictHostKeyChecking accept-new" >> $SSH_DIR/config
sudo -u $USERNAME echo "CheckHostIP no" >> $SSH_DIR/config


crudini --set $PIO_DIR/config.ini cluster.topology leader_hostname $(hostname)
crudini --set $PIO_DIR/config.ini cluster.topology leader_address $(hostname).local

sqlite3 $DB_LOC "INSERT OR IGNORE INTO experiments (created_at, experiment, description) VALUES (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'NOW'), 'Demo experiment', 'This is a demo experiment. Feel free to click around. When you are ready, click the [New experiment] above.');"
mosquitto_pub -t "pioreactor/latest_experiment" -m "Demo experiment" -r -q 1



sudo -u $USERNAME touch $PIO_DIR/config_$(hostname).ini # set with the correct read/write permissions
printf "# Any settings here are specific to $(hostname), and override the settings in config.ini\n\n" >> $PIO_DIR/config_$(hostname).ini
cp $PIO_DIR/config_$(hostname).ini $PIO_DIR/unit_config.ini
crudini --set $PIO_DIR/config.ini cluster.inventory $(hostname) 1