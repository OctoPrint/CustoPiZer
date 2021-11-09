# CustoPiZer for Pioreactor

Modify `input.img` with

```
docker run --rm --privileged -e LEADER=1 -v /path/to/workspace:/CustoPiZer/workspace/  -v /path/to/config.local:/CustoPiZer/config.local ghcr.io/octoprint/custopizer:latest
```


