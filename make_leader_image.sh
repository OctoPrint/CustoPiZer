#!/bin/bash

: ${1?"Usage: $0 PIO_VERSION"}

docker run --rm --privileged -e PIO_VERSION=$1 -e LEADER=1 -v /Users/camerondavidson-pilon/code/CustoPiZer/workspace:/CustoPiZer/workspace/  -v /Users/camerondavidson-pilon/code/CustoPiZer/config.local:/CustoPiZer/config.local ghcr.io/octoprint/custopizer:latest \
 && zip workspace/pioreactor_leader.img.zip workspace/output.img \
 && rm workspace/output.img
