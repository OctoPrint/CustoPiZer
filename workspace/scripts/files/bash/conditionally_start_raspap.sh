#!/bin/bash

set -x
set -e

export LC_ALL=C


WPA_FILE=/etc/wpa_supplicant/wpa_supplicant.conf
FLAG_FILE=/boot/local_access_point

# first, always update the SSID and passphrase to what's in the config.ini
sed -i "s/ssid=.*/ssid=$(crudini --get /home/pioreactor/.pioreactor/config.ini local_access_point ssid)/" /etc/hostapd/hostapd.conf
sed -i "s/wpa_passphrase=.*/wpa_passphrase=$(crudini --get /home/pioreactor/.pioreactor/config.ini local_access_point passphrase)/" /etc/hostapd/hostapd.conf

if [[ (! -f $FLAG_FILE) ]]; then
    # only execute if is enabled
    if [[ $(systemctl is-enabled hostapd.service) == "enabled" ]]; then
        # this order seems to be important.
        systemctl disable raspapd.service
        systemctl disable hostapd.service
        cp /etc/raspap/backups/dhcpcd.conf.original /etc/dhcpcd.conf
        systemctl daemon-reload
        systemctl restart wpa_supplicant.service
        systemctl restart dhcpcd.service
        pio log -m "Turning off hotspot and rebooting" -n raspap --local-only
        reboot
    fi
fi

if [[ (-f $FLAG_FILE) ]]; then
    # only execute if not enabled
    if [[ $(systemctl is-enabled hostapd.service) == "disabled" ]]; then
        # use the country code
        raspi-config nonint do_wifi_country $(sudo cat /boot/local_access_point)
        cp /etc/raspap/backups/dhcpcd.conf.raspap /etc/dhcpcd.conf
        systemctl daemon-reload
        systemctl restart dhcpcd.service
        systemctl enable raspapd.service
        systemctl enable hostapd.service
        pio log -m "Turning on hotspot and rebooting" -n raspap --local-only
        reboot
    fi
fi