# syntax=docker/dockerfile:1
ARG VERSION="bookworm"
FROM debian:${VERSION}
ARG VERSION

ENV PACKAGES="qemu-system qemu-user-static binfmt-support build-essential lsof sudo util-linux fdisk"

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends --yes ${PACKAGES} \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY . /CustoPiZer

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/CustoPiZer/customize" ]
