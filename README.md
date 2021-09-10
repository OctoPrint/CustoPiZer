# CustoPiZer

*A customization tool for Raspberry Pi OS images like OctoPi*

CustoPiZer is based on work done as part of the amazing [CustomPiOS](https://github.com/guysoft/CustomPiOS) and 
[OctoPi](https://github.com/guysoft/OctoPi) build scripts maintained by [Guy Sheffer](https://github.com/guysoft).

It allows to customize an OS image with a set of scripts that are run on the mounted image inside a qemu'd chroot. This is useful
to modify an existing image, e.g. to install additional software, prior to distributing it. The image is not booted, so unless the
scripts itself do anything that generate unique files, the image will stay shareable without the risk of sharing hard coded secrets,
keys or similar.

CustoPiZer was built for customization of OctoPi images by end users and vendors. It should however also work for generic images and
their customization. YMMV.

## Usage

Create a local workspace directory, place an image file therein named `input.img` and `scripts` containing your customization scripts.
If you need to make additional files available inside the image during build, place them inside `scripts/files` -- they will be mounted
inside the image build under `/files`. Then run CustoPiZer via Docker:

```
docker run --rm --privileged -v /path/to/workspace:/CustoPiZer/workspace ghcr.io/octoprint/custopizer:latest
```

Your customized image will be located in the `workspace` directory and named `output.img`.

### Why the `--privileged` flag?

CustoPiZer uses loopback mounts to mount the image partitions. Those don't seem to work in an unprivileged container. Happy to 
get info on how to circumvent this problem.

### Configuration

There are some configuration settings you can override by mounting a `config.local` file as `/CustoPiZer/config.local`. For the
available config settings, please take a look into the `EDITBASE_` variables in `src/config`.

If for example you want to override the enlarge and shrink sizes for the image build, mount something like this as `/CustoPiZer/config.local`:

``` bash
# enlarge image by 100MB prior to customization
EDITBASE_IMAGE_ENLARGEROOT=100

# shrink image to minimum size plus 20MB after customization
EDITBASE_IMAGE_RESIZEROOT=20
```

### Example

Place this in `workspace/scripts/01-update-octoprint`:

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

sudo -u pi /home/pi/oprint/bin/pip install -U OctoPrint
```

Place the image of the current [OctoPi release](https://octoprint.org/download) as `input.img` in `workspace`.

Run CustoPiZer. A new file `output.img` will be generated that only differs from the input in having seen its preinstalled OctoPrint
version now updated to the latest release.

### Inspecting an image

CustoPiZer also ships with an interactive `enter_image` script that mounts the image, starts the chrooted qemu, drops you into a bash, and on exit from that
unmounts and exists again.

This allows you to inspect an existing image prior or post modification, e.g. to test stuff out interactively. Be sure to always operate on a copy of the image
as the image *will* be changed by you interacting with it, even if only subtly (e.g. file timestamps).

To use, you have to slightly modify the docker call:

```
docker run -it --rm --privileged /path/to/image.img:/image.img ghcr.io/octoprint/custopizer:latest /CustoPiZer/enter_image /image.img
```

## Running from a GitHub Action

There's a composite action available that can be used as a step inside a GitHub Action workflow:

``` yaml
- name: Run CustoPiZer
  uses: OctoPrint/CustoPiZer@main
  with:
    workspace: "${{ github.workspace }}/build"
    scripts:  "${{ github.workspace }}/scripts"
```

It's also possible to pass on a JSON encoded object with additional environment variables to pass on to the docker call and make usable
inside the script context, e.g.:

``` yaml
- name: Run CustoPiZer
  uses: OctoPrint/CustoPiZer@main
  with:
    workspace: "${{ github.workspace }}/build"
    scripts:  "${{ github.workspace }}/scripts"
    environment: '{ "OCTOPRINT_VERSION": "${{ env.OCTOPRINT_VERSION }}" }'
```

> 👆 **Heads-up**
>
> Make sure to use *double quotes* for the JSON object keys and values, otherwise `jq` will raise a syntax error.
> 
> This is ok:
>
>     environment: '{ "OCTOPRINT_VERSION": "${{ env.OCTOPRINT_VERSION }}" }'
>
> This will fail:
>
>     environment: "{ 'OCTOPRINT_VERSION': '${{ env.OCTOPRINT_VERSION }}' }"

For a complex example usage that also includes repository dispatch, creating releases and attaching assets, take a look at the scripts and workflow of [OctoPrint/OctoPi-UpToDate](https://github.com/OctoPrint/OctoPi-UpToDate).

## Writing customization scripts

To ensure error handling is taken care of and some tooling is available, all customization scripts should start with these lines:

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap
```

The order in which scripts will be executed is by alphabetical sorting of the name, so it is strongly recommended to separate multiple steps
into scripts prefixed `01-`, `02-`, ... to ensure deterministic execution order.

Scripts are run as `root` user inside the image, so if you need to do things as a different user, use `sudo -u <user>`, e.g. `sudo -u pi`.

`common.sh` contains some helpful tools to streamline some common tasks at build time:

  * `unpack <source folder> <target folder> <target user>`: Copies files from source to target folder, `chown`ing to user and keeping dates and permissions
  * `is_installed <package>`: Succeeds if the package is already installed
  * `is_in_apt <package>`: Succeeds if the package is available in `apt`
  * `remove_if_installed <packages>`: Removes the packages if they are installed (interesting for decluttering)
  * `systemctl_if_exists <systemctl command...>`: Runs the `systemctl` command if `systemctl` is available
  * `pause <message>`: Display message and wait for enter to be pressed, useful for debugging
  * `echo_red <message>`: Display message in red
  * `echo_green <message>`: Display message in green

Any kind of non-`0` exit code will make the build fail, so make sure to develop your update scripts defensively. If a command might fail without
the whole build failing, use `|| true`, e.g. `rm some/file || true`.

Note that CustoPiZer will install a policy during build to ensure no services are started up, e.g. when installing new packages.

## Common tasks for customizing OctoPi

### Updating OctoPrint to the latest release

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

if [ -n "$OCTOPRINT_VERSION" ]; then
    sudo -u pi /home/pi/oprint/bin/pip install -U OctoPrint==$OCTOPRINT_VERSION
else
    sudo -u pi /home/pi/oprint/bin/pip install -U OctoPrint
fi
```

Note: This also allows you to specify the OctoPrint version to install by setting the environment variable `OCTOPRINT_VERSION` to our target version,
e.g.

```
docker run --rm --privileged \
  -e OCTOPRINT_VERSION=1.6.1 \
  -v /path/to/workspace:/CustoPiZer/workspace \
  ghcr.io/octoprint/custopizer:latest
```

or for the GitHub action:

``` yaml
- name: Run CustoPiZer
  uses: OctoPrint/CustoPiZer@main
  with:
    workspace: "${{ github.workspace }}/build"
    scripts:  "${{ github.workspace }}/scripts"
    environment: '{ "OCTOPRINT_VERSION": "1.6.1" }'
```

This also allows to install prereleases. If this environment variable is not set, the latest available release will be installed.

### Preinstalling additional plugins

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

plugins=(
    # add quoted URLs for install archives, separated by newlines, e.g.:
    "https://github.com/jneilliii/OctoPrint-BedLevelVisualizer/archive/master.zip"
    "https://github.com/FormerLurker/ArcWelderPlugin/archive/master.zip"
)

for plugin in ${plugins[@]}; do
    echo "Installing plugin from $plugin into OctoPrint venv..."
    sudo -u pi /home/pi/oprint/bin/pip install "$plugin"
done

```

### Adding additional tooling like `avrdude`

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

apt install --yes avrdude
```

### Customizing OctoPrint's configuration

Put the following script into `workspace/scripts/files/settings/merge-settings.py`:

``` python
#!/usr/bin/env python3
import yaml
import sys

def dict_merge(a, b, leaf_merger=None):
    """
    Recursively deep-merges two dictionaries.

    Taken from https://www.xormedia.com/recursively-merge-dictionaries-in-python/

    Arguments:
        a (dict): The dictionary to merge ``b`` into
        b (dict): The dictionary to merge into ``a``
        leaf_merger (callable): An optional callable to use to merge leaves (non-dict values)

    Returns:
        dict: ``b`` deep-merged into ``a``
    """

    from copy import deepcopy

    if a is None:
        a = dict()
    if b is None:
        b = dict()

    if not isinstance(b, dict):
        return b
    result = deepcopy(a)
    for k, v in b.items():
        if k in result and isinstance(result[k], dict):
            result[k] = dict_merge(result[k], v, leaf_merger=leaf_merger)
        else:
            merged = None
            if k in result and callable(leaf_merger):
                try:
                    merged = leaf_merger(result[k], v)
                except ValueError:
                    # can't be merged by leaf merger
                    pass

            if merged is None:
                merged = deepcopy(v)

            result[k] = merged
    return result

def merge_config_files(input_file, config_file):
    with open(input_file, mode="r", encoding="utf8") as f:
        to_merge = yaml.safe_load(f)

    with open(config_file, mode="r", encoding="utf8") as f:
        config = yaml.safe_load(f)
    
    merged = dict_merge(config, to_merge)

    with open(config_file, mode="w", encoding="utf8") as f:
        yaml.safe_dump(merged, f)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: merge-settings.py <input file> <target file>")
        sys.exit(-1)

    input_file = sys.argv[1]
    target_file = sys.argv[2]

    print(f"Merging {input_file} on {target_file}...")
    merge_config_files(input_file, target_file)
    print(f"Done!")
```

Place a yaml file containing the settings you wish to merge into OctoPrint's active `config.yaml` into `workspace/scripts/files/settings/settings.yaml`.

Then use this customization script:

``` bash
set -x
set -e

export LC_ALL=C

source /common.sh
install_cleanup_trap

# update config.yaml
sudo -u pi /home/pi/oprint/bin/python /files/settings/merge-settings.py /files/settings/settings.yaml /home/pi/.octoprint/config.yaml
```

> ✋ **Warning**
>
> Make sure to not ship any secret keys, passphrases, generated UUIDs or similar here. They will otherwise be the same across all instances created with
> this image!

