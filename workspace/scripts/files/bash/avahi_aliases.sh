#!/bin/bash

DOMAIN_ALIAS=$(crudini --get /home/pioreactor/.pioreactor/config.ini ui domain_alias)
IP=$(hostname -I | awk '{print $1}')

/usr/bin/avahi-publish -a -R        "$DOMAIN_ALIAS" "$IP" &
/usr/bin/avahi-publish -a -R "raspap.$DOMAIN_ALIAS" "$IP" &