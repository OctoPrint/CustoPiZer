# syntax=docker/dockerfile:1
ARG VERSION="trixie"
FROM debian:${VERSION}
ARG VERSION

ENV PACKAGES="qemu-system qemu-user binfmt-support build-essential lsof sudo util-linux fdisk e2fsprogs"

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends --yes ${PACKAGES} \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY . /CustoPiZer

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/CustoPiZer/customize" ]
