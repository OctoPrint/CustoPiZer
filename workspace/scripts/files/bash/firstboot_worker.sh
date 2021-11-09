#!/bin/bash

set -x
set -e

export LC_ALL=C


mkdir /home/pi/.ssh/
ssh-keygen -q -t rsa -N '' -f /home/pi/.ssh/id_rsa
cat /home/pi/.ssh/id_rsa.pub > /home/pi/.ssh/authorized_keys
ssh-keyscan -H $(hostname) >> /home/pi/.ssh/known_hosts
