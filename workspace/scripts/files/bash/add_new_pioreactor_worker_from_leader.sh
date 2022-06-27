#!/bin/bash
# this script "connects" the leader to the worker. It's possible (I think, because this appends to worker files),
# for more than one leader to "connect" to the
# same worker, so the worker can be used in multiple clusters.
# first argument is the hostname of the new pioreactor worker

set -x
set -e
export LC_ALL=C

export SSHPASS=raspberry

HOSTNAME=$1

USERNAME=pioreactor



# remove from known_hosts if already present
ssh-keygen -R $HOSTNAME.local          >/dev/null 2>&1
ssh-keygen -R $HOSTNAME                >/dev/null 2>&1


# allow us to SSH in, but make sure we can first before continuing.
# check we have .pioreactor folder to confirm the device has the pioreactor image
while ! sshpass -e ssh $HOSTNAME.local "test -d /home/$USERNAME/.pioreactor && echo 'exists'"
    do echo "Connection to $HOSTNAME.local missed - `date`"
    sleep 2
done


if ! avahi-browse _pioreactor_worker._tcp -t | grep -q $HOSTNAME; then
  echo "Unable to confirm if $HOSTNAME is a Pioreactor worker. Not found in 'avahi-browse _pioreactor_worker._tcp -t'. Did you install the worker image?"
  exit 1
fi

# copy public key over
sshpass -e ssh-copy-id $HOSTNAME.local

# remove any existing config (for idempotent)
# we do this first so the user can see it on the Pioreactors/ page
rm -f /home/$USERNAME/.pioreactor/config_$HOSTNAME.ini
touch /home/$USERNAME/.pioreactor/config_$HOSTNAME.ini
echo -e "# Any settings here are specific to $HOSTNAME, and override the settings in shared config.ini" >> /home/$USERNAME/.pioreactor/config_$HOSTNAME.ini
crudini --set /home/$USERNAME/.pioreactor/config.ini cluster.inventory $HOSTNAME 1

# add worker to known hosts on leader
ssh-keyscan $HOSTNAME.local >> /home/$USERNAME/.ssh/known_hosts
ssh-keyscan $HOSTNAME >> /home/$USERNAME/.ssh/known_hosts

# sync-configs
pios sync-configs --units $HOSTNAME
sleep 2

# check we have config.ini file to confirm the device has the necessary configuration
while ! sshpass -e ssh $HOSTNAME "test -f /home/$USERNAME/.pioreactor/config.ini && echo 'exists'"
    do echo "Looking for config.ini - `date`"
    sleep 2
done


# reboot once more (previous reboot didn't have config.inis)
# the || true is because the connection fails, which returns as -1.
ssh $HOSTNAME 'sudo reboot;' || true

exit 0
