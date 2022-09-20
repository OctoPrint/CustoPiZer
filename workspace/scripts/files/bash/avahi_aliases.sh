#!/bin/bash

DOMAIN_ALIAS=$(crudini --get /home/pioreactor/.pioreactor/config.ini ui domain_alias)
IP=$(avahi-resolve -4 -n $(hostname).local | cut -f 2)

/usr/bin/avahi-publish -a -R        $DOMAIN_ALIAS $IP &
/usr/bin/avahi-publish -a -R raspap.$DOMAIN_ALIAS $IP &