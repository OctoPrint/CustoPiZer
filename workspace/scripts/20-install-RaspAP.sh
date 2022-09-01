set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


INSTALLER=https://raw.githubusercontent.com/Pioreactor/raspap-webgui/master/installers/raspbian.sh


if [ "$LEADER" == "1" ]; then
    sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.original

    # we modified the installer slightly to work with qemu. It's possible we
    curl -sL $INSTALLER | bash -s -- --yes --openvpn 0 --adblock 0 --repo Pioreactor/raspap-webgui --branch master

    # change port of webserver to not conflict with pioreactor.local
    sed -i "s/server.port                 = 80/server.port                 = 8080/" /etc/lighttpd/lighttpd.conf

    # change the dns server to AP machine. This IP is coded by RaspAP.
    sed -i "s/dhcp-option=6.*$/dhcp-option=6,10.3.141.1/" /etc/dnsmasq.d/090_wlan0.conf


    # turn off by default. It's turned on by conditionally_start_raspap.sh, which is called by a service on boot.
    sudo systemctl disable raspapd.service
    sudo systemctl disable hostapd.service

    # swap back old dhcpcd file
    sudo mv /etc/dhcpcd.conf /etc/raspap/backups/dhcpcd.conf.raspap
    sudo mv /etc/dhcpcd.conf.original /etc/raspap/backups/dhcpcd.conf.original
    sudo cp /etc/raspap/backups/dhcpcd.conf.original /etc/dhcpcd.conf
fi