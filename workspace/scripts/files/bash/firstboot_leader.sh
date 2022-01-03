#!/bin/bash

set -x
set -e

export LC_ALL=C


PIO_DIR=/home/pi/.pioreactor

sudo -u pi ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
sudo -u pi cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
sudo -u pi ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts


crudini --set $PIO_DIR/config.ini network.topology leader_hostname $(hostname)
crudini --set $PIO_DIR/config.ini network.topology leader_address $(hostname).local

# techdebt: seed_initial_experiment.sql adds an experiment to the db, so we need to match it in mqtt too
# this happens in firstboot and not in the image because mqtt will only save to disk every 5m, so it's
# never stored on the image. However, from docs:
mosquitto_pub -t "pioreactor/latest_experiment" -m "Demo experiment" -r


# we need to alias pioreactor.local to leader's hostname at boot, otherwise we run instead
# avahi-publish -a -R pioreactor.local 127.0.0.1
# since that's the IP address when the image is hosted.
sudo systemctl restart avahi-alias.service


# attempt backup database every N days
# the below overwrites any existing crons
# this doesn't persist if preinstalled on the image.
echo "0 0 */5 * * /usr/local/bin/pio run backup_database" | crontab -