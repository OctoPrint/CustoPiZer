#!/bin/bash

# arg1 is the name of the plugin to install
set +e
set -x
export LC_ALL=C

plugin_name=$1


# the below can fail, and will fail on a worker
# delete yamls from pioreactorui
plugin_name_with_underscores=${plugin_name//-/_}
(cd /usr/local/lib/python3.9/dist-packages/pioreactor_air_bubbler/ui/contrib/ && find * -type f) | awk '{print "/home/pioreactor/pioreactorui/backend/contrib/"$1}' | xargs rm

# remove config.ini
# TODO. crudini isn't much help here.


sudo pip3 uninstall  --root-user-action=ignore  -y $plugin_name
