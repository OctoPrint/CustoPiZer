#!/bin/bash

set -x
set -e

export LC_ALL=C


sudo -u pi ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
sudo -u pi cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
sudo -u pi ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts
