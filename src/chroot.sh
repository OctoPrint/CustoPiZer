#!/usr/bin/env bash
# based on CustomPiOS by Guy Sheffer <guy at gmail dot com>

## chroot helpers

function prepare_chroot_environment() {
  # figure out which qemu to use - if any - and ensure its availability & functionality inside the chroot
  if [ "$(arch)" != "armv7l" ] && [ "$(arch)" != "aarch64" ] && [ "$(arch)" != "arm64" ] ; then
    if [ "$EDITBASE_ARCH" == "armv7l" ]; then
      # cross-compile for arm 32bit
      update-binfmts --enable qemu-arm
      cp `which qemu-arm-static` usr/bin/qemu-arm-static
      export QEMU=usr/bin/qemu-arm-static

    elif [ "$EDITBASE_ARCH" == "aarch64" ] || [ "$EDITBASE_ARCH" == "arm64" ]; then
      # cross-compile for arm 64bit
      update-binfmts --enable qemu-aarch64
      cp `which qemu-aarch64-static` usr/bin/qemu-aarch64-static
      export QEMU=usr/bin/qemu-aarch64-static
    fi

    (mount | grep -q -v "type binfmt_misc") || mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

  else
    # arch native
    export QEMU=
  fi

  # mount /proc if configured to do so
  if [ "$EDITBASE_MOUNT_PROC" == "1" ]; then
    echo "Mounting /proc of host..."
    mount -t proc /proc proc/
  fi

  # mount /sys if configured to do so
  if [ "$EDITBASE_MOUNT_SYS" == "1" ]; then
    echo "Mounting /sys of host..."
    mount -t sysfs /sys sys/
  fi
}
