#!/bin/bash

# arg1 is the name of the plugin to install
# arg2 is the url, wheel, etc., possible None.
set -e
set -x
export LC_ALL=C

USERNAME=pioreactor
plugin_name=$1
other=$2
install_folder=/usr/local/lib/python3.9/dist-packages/${plugin_name//-/_}

if [ -n "$other" ]
then
    sudo pip3 install -U --root-user-action=ignore -I "$other"
else
    sudo pip3 install -U --root-user-action=ignore -I "$plugin_name"
fi


# the below can fail, and will fail on a worker
set +e

# merge new config.ini
crudini --merge /home/$USERNAME/.pioreactor/config.ini < "$install_folder/additional_config.ini"

# add any new sql
sqlite3 "$(crudini --get /home/pioreactor/.pioreactor/config.ini storage database)" < "$install_folder/additional_sql.sql"

# merge UI contribs
rsync -a "$install_folder/ui/contrib/" /var/www/pioreactorui/contrib/

# broadcast to cluster
pios sync-configs

exit 0
