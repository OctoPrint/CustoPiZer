# CustoPiZer for Pioreactor

Modify `input.img`, the unzipped latest Raspberry Pi OS Lite image, with

```
docker run --rm --privileged \
    -e PIO_VERSION=21.11.1  \
    -e LEADER=1\
    -e WORKER=1\
    -e EDITBASE_OUTPUT_NAME=leader_worker.img\
    -v /path/to/workspace:/CustoPiZer/workspace/\
    -v /path/to/config.local:/CustoPiZer/config.local\
    ghcr.io/octoprint/custopizer:latest
```



### FAQ

1. How do I update to the image to the latest Pioreactor version?

Change the arg in the invocation.

2. How do I change the output name?

`EDITBASE_OUTPUT_NAME` - but I need to rebuild the docker image so it's **not working**.

