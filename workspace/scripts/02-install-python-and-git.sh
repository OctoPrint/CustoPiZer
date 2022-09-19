set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap


sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y python3-pip
sudo pip3 install pip -U  # update to latest pip
sudo pip3 config set global.disable-pip-version-check true
