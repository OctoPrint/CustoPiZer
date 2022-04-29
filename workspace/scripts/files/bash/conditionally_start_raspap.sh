#!/bin/bash

set -x
set -e

export LC_ALL=C


WPA_FILE=/etc/wpa_supplicant/wpa_supplicant.conf
RASPAP_TRIGGER_ON_PIN=20
RASPAP_TRIGGER_OFF_PIN=26



# If GPIO 26 is pulled HIGH, then stop and disable the RaspAP access point, but only if there are WIFI credentials to use
if [[ (-f $WPA_FILE) && $(raspi-gpio get $RASPAP_TRIGGER_OFF_PIN | cut -d " " -f 3) == "level=1" ]]; then
    # only execute if is enabled
    if [[ $(systemctl is-enabled hostapd.service) == "enabled" ]]; then
        # this order seems to be important.
        systemctl disable raspapd.service --now
        systemctl disable hostapd.service --now
        cp /etc/raspap/backups/dhcpcd.conf.original /etc/dhcpcd.conf
        systemctl daemon-reload
        systemctl restart wpa_supplicant.service
        systemctl restart dhcpcd.service
        pio log -m "Turning off hotspot" -n raspap
    fi
fi

# If there are no WIFI credentials, or GPIO 20 is pulled HIGH, then enable and start the RaspAP access point
if [[ (! -f $WPA_FILE) || $(raspi-gpio get $RASPAP_TRIGGER_ON_PIN | cut -d " " -f 3) == "level=1" ]]; then
    # only execute if not enabled
    if [[ $(systemctl is-enabled hostapd.service) == "disabled" ]]; then
        cp /etc/raspap/backups/dhcpcd.conf.raspap /etc/dhcpcd.conf
        systemctl daemon-reload
        systemctl restart dhcpcd.service
        systemctl enable raspapd.service --now
        systemctl enable hostapd.service --now
        pio log -m "Turning on hotspot" -n raspap
    fi
fi