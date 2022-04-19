set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

USERNAME=pioreactor
PASS=raspberry

adduser --gecos "" --disabled-password $USERNAME
chpasswd <<<"$USERNAME:$PASS"
usermod -a -G gpio $USERNAME
usermod -a -G spi $USERNAME
usermod -a -G i2c $USERNAME