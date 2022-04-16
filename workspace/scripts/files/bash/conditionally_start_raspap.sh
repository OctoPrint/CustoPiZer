#!/bin/bash

set -x
set -e

export LC_ALL=C


WPA_FILE=/etc/wpa_supplicant

# If there are no WIFI credentials, or GPIO is pulled HIGH, then start the raspap service
if [ -f $WPA_FILE ] && [ $(raspi-gpio get 20 | cut -d " " -f 3) == "level=0" ]; then
    sudo systemctl disable raspapd.service
else
    sudo systemctl enable raspapd.service
fi