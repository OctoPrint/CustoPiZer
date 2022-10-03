#!/bin/bash

DOMAIN_ALIAS=$(crudini --get /home/pioreactor/.pioreactor/config.ini ui domain_alias)
IP=$(hostname -I | awk '{print $1}')

while [ "$IP" == "127.0.0.1" ]
do
    sleep 2
    IP=$(hostname -I | awk '{print $1}')
done


/usr/bin/avahi-publish -a -R        "$DOMAIN_ALIAS" "$IP" &
/usr/bin/avahi-publish -a -R "raspap.$DOMAIN_ALIAS" "$IP" &