#!/bin/bash

set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


# add everyboot
sudo cp /files/system/systemd/everyboot.service /lib/systemd/system/
sudo systemctl enable everyboot.service
cp /files/bash/everyboot.sh /usr/local/bin/everyboot.sh