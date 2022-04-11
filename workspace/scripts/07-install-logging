set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

USERNAME=pioreactor

sudo touch /var/log/pioreactor.log
sudo chown $USERNAME /var/log/pioreactor.log

# add a logrotate entry
sudo cp /files/system/logrotate/pioreactor /etc/logrotate.d/pioreactor

