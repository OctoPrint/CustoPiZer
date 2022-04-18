#!/bin/bash

set -x
set -e

export LC_ALL=C


WPA_FILE=/etc/wpa_supplicant/wpa_supplicant.conf
RASPAP_TRIGGER_ON_PIN=20
RASPAP_TRIGGER_OFF_PIN=26


# If GPIO 26 is pulled HIGH, then stop and disable the RaspAP access point
if [[ $(raspi-gpio get $RASPAP_TRIGGER_OFF_PIN | cut -d " " -f 3) == "level=1" ]]; then
    sudo systemctl disable raspapd.service --now
    sudo systemctl disable hostapd.service --now
fi

# If there are no WIFI credentials, or GPIO 20 is pulled HIGH, then enable and start the RaspAP access point
if [[ (! -f $WPA_FILE) || $(raspi-gpio get $RASPAP_TRIGGER_ON_PIN | cut -d " " -f 3) == "level=1" ]]; then
    sudo systemctl enable raspapd.service --now
    sudo systemctl enable hostapd.service --now
fi