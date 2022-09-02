set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

USERNAME=pioreactor
UI_FOLDER=/home/$USERNAME/pioreactorui

if [ "$LEADER" == "1" ]; then
    # install NPM and Node
    wget -O - https://raw.githubusercontent.com/audstanley/NodeJs-Raspberry-Pi/master/Install-Node.sh | sudo bash

    # get latest pioreactorUI code from Github.
    sudo -u $USERNAME git clone https://github.com/Pioreactor/pioreactorui.git $UI_FOLDER  --depth 1

    cp $UI_FOLDER/backend/.env.example $UI_FOLDER/backend/.env

    # install required libraries for backend
    # TODO: fix npm6, hitting this issue https://github.com/npm/cli/issues/3577
    npm install -g npm@6
    sudo npm --prefix $UI_FOLDER/backend install
    sudo npm install pm2@5.1.2 -g

    # we add another entry to mDNS: pioreactor.local (can be modified in config.ini), and we need the following:
    # see avahi_alias.service for how this works
    sudo apt-get install avahi-utils -y

    # iptables USE to ship with RPi OS, not any more?
    sudo apt-get install iptables -y
fi