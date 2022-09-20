set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

UI_FOLDER=/var/www/pioreactorui

if [ "$LEADER" == "1" ]; then

    # needed for fast yaml
    apt-get install libyaml-dev -y
    # https://github.com/yaml/pyyaml/issues/445
    sudo pip3 install --no-cache-dir --no-binary pyyaml pyyaml


    # get latest pioreactorUI code from Github.
    git clone https://github.com/Pioreactor/pioreactorui.git $UI_FOLDER  --depth 1
    # install the dependencies
    sudo pip3 install -r $UI_FOLDER/requirements.txt

    # init .env
    mv $UI_FOLDER/.env.example $UI_FOLDER/.env

    # make correct permissions in new www folders
    # https://superuser.com/questions/19318/how-can-i-give-write-access-of-a-folder-to-all-users-in-linux
    chgrp -R www-data /var/www
    chmod -R g+w /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod ug+rw {} \;
    chmod +x $UI_FOLDER/main.fcgi

    # install lighttp and set up mods
    apt-get install lighttpd -y
    cp /files/system/lighttpd/50-pioreactorui.conf /etc/lighttpd/conf-available/50-pioreactorui.conf

    lighttpd-enable-mod fastcgi
    lighttpd-enable-mod pioreactorui

    # we add entries to mDNS: pioreactor.local (can be modified in config.ini), and we need the following:
    # see avahi_aliases.service for how this works
    sudo apt-get install avahi-utils -y

fi