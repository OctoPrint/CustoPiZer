# CustoPiZer for Pioreactor

Modify `input.img`, the unzipped latest Raspberry Pi OS Lite image, with

```
docker run --rm --privileged
    -e LEADER=1
    -e WORKER=1
    -e EDITBASE_OUTPUT_NAME=leader_worker.img
    -v /path/to/workspace:/CustoPiZer/workspace/
    -v /path/to/config.local:/CustoPiZer/config.local
    ghcr.io/octoprint/custopizer:latest
```



### FAQ

1. How do I update to the image to the latest Pioreactor version?

It's the version is located in the `config.local`.

2. How do I change the output name?

`EDITBASE_OUTPUT_NAME` - but I need to rebuild the docker image so it's **not working**.

