FROM debian:buster

RUN set -x \
    && apt-get update && apt-get install -y \
        build-essential \
        binfmt-support \
        qemu \
        qemu-user-static \
        sudo \
        lsof \
    && rm -rf /var/lib/apt/lists/*

COPY . /CustoPiZer

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/CustoPiZer/customize" ]