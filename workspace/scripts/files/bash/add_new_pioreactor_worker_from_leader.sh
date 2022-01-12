#!/bin/bash
# this script "connects" the leader to the worker. It's possible (I think, because this appends to worker files),
# for more than one leader to "connect" to the
# same worker, so the worker can be used in multiple clusters.
# first argument is the hostname of the new pioreactor worker
# TODO: make the second argument the required password

set -x
set -e
export LC_ALL=C

export SSHPASS=raspberry

HOSTNAME=$1


# remove from known_hosts if already present
ssh-keygen -R $HOSTNAME.local                                                       >/dev/null 2>&1
ssh-keygen -R $HOSTNAME                                                             >/dev/null 2>&1
ssh-keygen -R $(host $HOSTNAME | awk '/has address/ { print $4 ; exit }')           >/dev/null 2>&1


# allow us to SSH in, but make sure we can first before continuing.
while ! sshpass -e ssh -o StrictHostKeyChecking=no $HOSTNAME "true"
    do echo "SSH to $HOSTNAME missed - `date`"
    sleep 2
done

cat ~/.ssh/id_rsa.pub | sshpass -e ssh -o StrictHostKeyChecking=no $HOSTNAME 'cat >> .ssh/authorized_keys'

# remove any existing config (for idempotent)
# we do this first so the user can see it on the Pioreactors/ page
rm -f /home/pi/.pioreactor/config_$HOSTNAME.ini
touch /home/pi/.pioreactor/config_$HOSTNAME.ini
echo -e "# Any settings here are specific to $HOSTNAME, and override the settings in shared config.ini" >> /home/pi/.pioreactor/config_$HOSTNAME.ini
crudini --set /home/pi/.pioreactor/config.ini network.inventory $HOSTNAME 1

# add to known hosts
ssh-keyscan -H $HOSTNAME >> /home/pi/.ssh/known_hosts

# sync-configs
pios sync-configs --units $HOSTNAME
sleep 2

# reboot once more (previous reboot didn't have config.inis)
ssh -o StrictHostKeyChecking=no $HOSTNAME 'sudo reboot;'

exit 0
