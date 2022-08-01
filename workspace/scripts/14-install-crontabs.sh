set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

USERNAME=pioreactor
UI_DIR=/home/pioreactorui


if [ "$LEADER" == "1" ]; then
    # crons don't persist if preinstalled on the image.
    crontab -e $USERNAME
    # attempt backup database every N days
    (sudo -u $USERNAME crontab -l ; echo "0 0 */5 * * /usr/local/bin/pio run backup_database") | sudo -u $USERNAME crontab -

    # remove dataset exports in /home/pioreactor/pioreactorui/backend/build/static/exports
    (sudo -u $USERNAME crontab -l ; echo "0 0 */29 * * rm $UI_DIR/backend/build/static/exports/*.zip $UI_DIR/backend/build/static/exports/*.csv") | sudo -u $USERNAME crontab -
fi