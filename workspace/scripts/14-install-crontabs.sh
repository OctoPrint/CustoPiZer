set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

USERNAME=pioreactor


if [ "$LEADER" == "1" ]; then
    crontab -u pioreactor /files/pioreactor.cron
fi