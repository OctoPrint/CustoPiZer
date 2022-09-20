#!/bin/bash

# arg1 is the name of the plugin to install
# arg2 is the url, wheel, etc., possible None.
set -e
set -x
export LC_ALL=C

USERNAME=pioreactor
plugin_name=$1
other=$2


if [ ! -z $other ]
then
    sudo pip3 install -U --root-user-action=ignore -I $other
else
    sudo pip3 install -U --root-user-action=ignore -I $plugin_name
fi


# the below can fail, and will fail on a worker
set +e

plugin_name_with_underscores=${plugin_name//-/_}

crudini --merge /home/$USERNAME/.pioreactor/config.ini < /usr/local/lib/python3.9/dist-packages/$plugin_name_with_underscores/additional_config.ini
rsync -a /usr/local/lib/python3.9/dist-packages/$plugin_name_with_underscores/ui/contrib/ /var/www/pioreactorui/contrib/
pios sync-configs

exit 0
