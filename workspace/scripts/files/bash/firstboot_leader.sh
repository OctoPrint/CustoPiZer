#!/bin/bash

set -x
set -e

export LC_ALL=C


PIO_DIR=/home/pi/.pioreactor

mkdir /home/pi/.ssh/
ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
sudo apt install sshpass
cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts

crudini --set $PIO_DIR/config.ini network.topology leader_hostname $(hostname)
crudini --set $PIO_DIR/config.ini network.topology leader_address $(hostname).local

