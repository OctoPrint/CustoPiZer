#!/bin/bash

set -x
set -e

export LC_ALL=C


PIO_DIR=/home/pi/.pioreactor

sudo apt install sshpass
mkdir /home/pi/.ssh/
ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts

crudini --set $PIO_DIR/config.ini network.topology leader_hostname $(hostname)
crudini --set $PIO_DIR/config.ini network.topology leader_address $(hostname).local

touch $PIO_DIR/config_$(hostname).ini
printf "# Any settings here are specific to $(hostname), and override the settings in config.ini\n\n" >> /home/pi/.pioreactor/config_$(hostname).ini
cp $PIO_DIR/config_$(hostname).ini $PIO_DIR/unit_config.ini
crudini --set $PIO_DIR/config.ini network.inventory $(hostname) 1

# techdebt: seed_initial_experiment.sql adds an experiment to the db, so we need to match it in mqtt too
# this happens in firstboot and not in the image because mqtt will only save to disk every 5m, so it's
# never stored on the image. However, from docs:
mosquitto_pub -t "pioreactor/latest_experiment" -m "Demo experiment" -r