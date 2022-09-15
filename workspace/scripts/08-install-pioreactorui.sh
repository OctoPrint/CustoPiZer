set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

UI_FOLDER=/var/www/pioreactor

if [ "$LEADER" == "1" ]; then

    # install lighttp and set up mods
    apt-get install lighttpd
    cp /files/lighttpd/50-pioreactorui.conf /etc/lighttpd/conf-available/50-pioreactorui.conf

    lighttpd-enable-mod fastcgi
    lighttpd-enable-mod pioreactorui


    mkdir $UI_FOLDER

    # get latest pioreactorUI code from Github.
    git clone https://github.com/Pioreactor/pioreactorui_backend.git $UI_FOLDER  --depth 1
    # install the dependencies
    pip3 install -r $UI_FOLDER/requirements.txt

    # init .env
    mv $UI_FOLDER/.env.example $UI_FOLDER/.env

    # set up permissions so www-data can read these files
    chmod +x $UI_FOLDER/app.fcgi # TODO
    chown -R www-data:www-data $UI_FOLDER

    # we add another entry to mDNS: pioreactor.local (can be modified in config.ini), and we need the following:
    # see avahi_aliases.service for how this works
    sudo apt-get install avahi-utils -y

fi