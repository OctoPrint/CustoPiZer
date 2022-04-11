set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


if [ "$LEADER" == "1" ]; then
    cp /files/bash/add_new_pioreactor_worker_from_leader.sh /usr/local/bin/
fi

cp /files/bash/install_pioreactor_plugin.sh /usr/local/bin/
cp /files/bash/uninstall_pioreactor_plugin.sh /usr/local/bin/
