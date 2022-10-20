#!/bin/bash

set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

if [ "$WORKER" == "1" ]; then

    apt-get install -y libftdi-dev libusb-1.0-0-dev

    # move executable
    mkdir /usr/local/bin/openocd/
    cp /files/system/openocd/openocd /usr/local/bin/openocd/

    # move config
    mkdir /usr/local/share/openocd/
    cp -r /files/system/openocd/contrib   /usr/local/share/openocd/
    cp -r /files/system/openocd/OpenULINK /usr/local/share/openocd/
    cp -r /files/system/openocd/scripts   /usr/local/share/openocd/

    # TODO: move .elf image here too

fi