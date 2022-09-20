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
    # sudo cp /files/system/systemd/start_pioreactorui.service $SYSTEMD_DIR
    # sudo systemctl enable start_pioreactorui.service
    # TODO: do I need a lighttp service??
    sudo cp /files/system/systemd/huey.service $SYSTEMD_DIR
    sudo systemctl enable huey.service

    # systemd: add long running pioreactor jobs
    sudo systemctl enable pioreactor_startup_run_always@watchdog.service
    sudo systemctl enable pioreactor_startup_run_always@mqtt_to_db_streaming.service

    # systemd: alias hostname to pioreactor.local
    sudo cp /files/system/systemd/avahi_aliases.service $SYSTEMD_DIR
    sudo systemctl enable avahi_aliases.service
    cp /files/bash/avahi_aliases.sh /usr/local/bin/avahi_aliases.sh


    # add avahi services
    sudo cp /files/system/avahi/mqtt.service /etc/avahi/services/
    sudo cp /files/system/avahi/pioreactorui.service /etc/avahi/services/

    # install raspap service check
    sudo cp /files/system/systemd/start_raspap.service $SYSTEMD_DIR
    sudo systemctl enable start_raspap.service
    cp /files/bash/conditionally_start_raspap.sh /usr/local/bin/conditionally_start_raspap.sh
fi


if [ "$WORKER" == "1" ]; then
    # add avahi services
    sudo cp /files/system/avahi/pioreactor_worker.service /etc/avahi/services/
fi


# disable things that slow down boot
sudo systemctl disable raspi-config.service
sudo systemctl disable triggerhappy.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily-upgrade.service
sudo systemctl disable alsa-restore.service


