set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


# add everyboot
sudo cp /files/system/systemd/everyboot.service $SYSTEMD_DIR
sudo systemctl enable everyboot.service
cp /files/bash/everyboot.sh /boot/everyboot.sh