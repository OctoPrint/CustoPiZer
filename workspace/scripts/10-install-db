set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

USERNAME=pioreactor

# install sqlite3 on all machines, as I expect I'll use it on workers one day.
sudo apt-get install -y sqlite3



if [ "$LEADER" == "1" ]; then

    DB_LOC=/home/$USERNAME/.pioreactor/storage/pioreactor.sqlite

    sudo -u $USERNAME touch $DB_LOC
    sqlite3 $DB_LOC < /files/sql/sqlite_configuration.sql
    sqlite3 $DB_LOC < /files/sql/create_tables.sql

fi


