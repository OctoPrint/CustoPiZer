#!/bin/bash

set -x
set -e

export LC_ALL=C


# set up SSH (leader only)
rm -f /home/pi/.ssh/id_rsa
ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
sudo apt install sshpass
cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts



# config.ini stuff (leader only)
crudini --set ~/.pioreactor/config.ini network.topology leader_hostname $(hostname)
crudini --set ~/.pioreactor/config.ini network.topology leader_address $(hostname).local


# leader AND worker
touch /home/pi/.pioreactor/config_$(hostname).ini
printf "# Any settings here are specific to $(hostname), and override the settings in config.ini\n\n" >> /home/pi/.pioreactor/config_$(hostname).ini
cp /home/pi/.pioreactor/config_$(hostname).ini /home/pi/.pioreactor/unit_config.ini
crudini --set ~/.pioreactor/config.ini network.inventory $(hostname) 1
