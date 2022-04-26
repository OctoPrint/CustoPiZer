#!/bin/bash

: ${1?"Usage: $0 PIO_VERSION"}

GIT_COMMIT="$(git show --format="%h" --no-patch)"

OUTPUT=pioreactor_worker.img.zip

rm -f workspace/$OUTPUT

docker run --rm --privileged \
    -e PIO_VERSION=$1 \
    -e CUSTOPIZER_GIT_COMMIT=$GIT_COMMIT \
    -e WORKER=1 \
    -e LEADER=0 \
    -v /Users/camerondavidson-pilon/code/CustoPiZer/workspace:/CustoPiZer/workspace/  -v /Users/camerondavidson-pilon/code/CustoPiZer/config.local:/CustoPiZer/config.local ghcr.io/octoprint/custopizer:latest \
 && (cd workspace/; zip $OUTPUT output.img) \
 && rm workspace/output.img