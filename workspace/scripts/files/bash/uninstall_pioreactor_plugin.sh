#!/bin/bash

# arg1 is the name of the plugin to install
set +e
set -x
export LC_ALL=C

plugin_name=$1


# the below can fail, and will fail on a worker
# delete yamls from pioreactorui
plugin_name_with_underscores=${plugin_name//-/_}
(cd /usr/local/lib/python3.9/dist-packages/"$plugin_name_with_underscores"/ui/contrib/ && find * -type f) | awk '{print "/var/www/pioreactorui/contrib/"$1}' | xargs rm

# remove config.ini
# TODO. crudini isn't much help here.

sudo pip3 uninstall  --root-user-action=ignore  -y "$plugin_name"

# broadcast to cluster
pios sync-configs

exit 0