# CustoPiZer for Pioreactor

This repo contains the scripts to serially modify an original RPi image (say, from the RPi Foundation), to add Pioreactor software and files.

### How does it work?

When a new release is made in [pioreactor/pioreactor](https://github.com/Pioreactor/pioreactor), a dispatch is sent to this repo using Github Actions, including the version of Pioreactor software to use. A new workflow is kicked off that builds the images, creates a new release, and attaches the images to the release.

The following url will point to a specific asset in the latest release:
```
https://github.com/pioreactor/custopizer/releases/latest/download/<asset_name>
```



### Local build:

With docker running:

```
bash make_leader_image <version>
```
