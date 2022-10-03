#!/bin/bash

set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap



cp /files/system/systemd/firstboot.service /lib/systemd/system/
cd /etc/systemd/system/multi-user.target.wants && ln -s /lib/systemd/system/firstboot.service .  # why do I do this??


if [ "$LEADER" == "1" ] && [ "$WORKER" == "1" ]; then
    cp /files/bash/firstboot_leader_and_worker.sh /usr/local/bin/firstboot.sh
elif [ "$LEADER" == "1" ]; then
    cp /files/bash/firstboot_leader.sh /usr/local/bin/firstboot.sh
elif [ "$WORKER" == "1" ]; then
    cp /files/bash/firstboot_worker.sh /usr/local/bin/firstboot.sh
fi