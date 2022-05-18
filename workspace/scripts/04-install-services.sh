set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

# systemd: add long running pioreactor jobs

SYSTEMD_DIR=/lib/systemd/system/

sudo cp /files/system/systemd/pioreactor_startup_run_always@.service $SYSTEMD_DIR
sudo systemctl enable pioreactor_startup_run_always@monitor.service

# systemd: remove wifi powersave - helps with mdns discovery
sudo cp /files/system/systemd/wifi_powersave.service $SYSTEMD_DIR
sudo systemctl enable wifi_powersave.service


if [ "$LEADER" == "1" ]; then
    sudo cp /files/system/systemd/ngrok.service $SYSTEMD_DIR

    # systemd: web UI
    sudo cp /files/system/systemd/start_pioreactorui.service $SYSTEMD_DIR
    sudo systemctl enable start_pioreactorui.service

    # systemd: add long running pioreactor jobs
    sudo systemctl enable pioreactor_startup_run_always@watchdog.service
    sudo systemctl enable pioreactor_startup_run_always@mqtt_to_db_streaming.service

    # systemd: alias hostname to pioreactor.local
    sudo cp /files/system/systemd/avahi_alias.service $SYSTEMD_DIR
    sudo systemctl enable avahi_alias.service

    # add avahi services
    sudo cp /files/system/avahi/mqtt.service /etc/avahi/services/
    sudo cp /files/system/avahi/pioreactorui.service /etc/avahi/services/

    # install raspap service check
    sudo cp /files/system/systemd/start_raspap.service $SYSTEMD_DIR
    sudo systemctl enable start_raspap.service
    cp /files/bash/conditionally_start_raspap.sh /boot/conditionally_start_raspap.sh
fi



