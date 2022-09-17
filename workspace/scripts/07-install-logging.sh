set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

USERNAME=pioreactor

sudo touch /var/log/pioreactor.log
sudo chown pioreactor:pioreactor /var/log/pioreactor.log
# give free conditions so anyone can write to it if needed, ie. www-data
sudo chmod 666 /var/log/pioreactor.log

# create pioreactorui logs
sudo touch /var/log/pioreactorui.log
sudo chown www-data:www-data /var/log/pioreactorui.log

# add a logrotate entry
sudo cp /files/system/logrotate/pioreactor /etc/logrotate.d/pioreactor
sudo cp /files/system/logrotate/pioreactorui /etc/logrotate.d/pioreactorui

