#!/bin/bash

set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

IMAGE_METADATA_FILE=/home/pioreactor/.pioreactor/.image_metadata
TODAY=$(date +%F)

touch $IMAGE_METADATA_FILE
echo "CUSTOPIZER_GIT_COMMIT=$CUSTOPIZER_GIT_COMMIT" >> $IMAGE_METADATA_FILE
echo "DATE=$TODAY" >> $IMAGE_METADATA_FILE
echo "WORKER=$WORKER" >> $IMAGE_METADATA_FILE
echo "LEADER=$LEADER" >> $IMAGE_METADATA_FILE
echo "PIO_VERSION_ORIGINALLY_INSTALLED=$PIO_VERSION" >> $IMAGE_METADATA_FILE