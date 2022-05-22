#!/bin/bash

set -x
set -e

export LC_ALL=C

USERNAME=pioreactor
PIO_DIR=/home/$USERNAME/.pioreactor
SSH_DIR=/home/$USERNAME/.ssh

sudo -u $USERNAME rm -rf $SSH_DIR # remove if already exists.


sudo -u $USERNAME mkdir -p $SSH_DIR
sudo -u $USERNAME touch $SSH_DIR/authorized_keys
sudo -u $USERNAME touch $SSH_DIR/known_hosts

sudo -u $USERNAME ssh-keygen -q -t rsa -N '' -f $SSH_DIR/id_rsa
sudo -u $USERNAME cat $SSH_DIR/id_rsa.pub > $SSH_DIR/authorized_keys
sudo -u $USERNAME ssh-keyscan $(hostname) >> $SSH_DIR/known_hosts
sudo -u $USERNAME echo "StrictHostKeyChecking accept-new" >> $SSH_DIR/config


crudini --set $PIO_DIR/config.ini network.topology leader_hostname $(hostname)
crudini --set $PIO_DIR/config.ini network.topology leader_address $(hostname).local

# techdebt: seed_initial_experiment.sql adds an experiment to the db, so we need to match it in mqtt too
# this happens in firstboot and not in the image because mqtt will only save to disk every 5m, so it's
# never stored on the image.
mosquitto_pub -t "pioreactor/latest_experiment" -m "Demo experiment" -r -q 1


# attempt backup database every N days
# the below overwrites any existing crons
# this doesn't persist if preinstalled on the image.
echo "0 0 */5 * * /usr/local/bin/pio run backup_database" | crontab -


sudo -u $USERNAME touch $PIO_DIR/config_$(hostname).ini # set with the correct read/write permissions
printf "# Any settings here are specific to $(hostname), and override the settings in config.ini\n\n" >> $PIO_DIR/config_$(hostname).ini
cp $PIO_DIR/config_$(hostname).ini $PIO_DIR/unit_config.ini
crudini --set $PIO_DIR/config.ini network.inventory $(hostname) 1