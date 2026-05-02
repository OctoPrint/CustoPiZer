#!/usr/bin/env bash
# based on CustomPiOS by Guy Sheffer <guy at gmail dot com>

## chroot helpers

# Register a qemu-user-static binfmt_misc entry with the CF flags:
#   C - kernel derives credentials from the binary (preserves suid, e.g. sudo).
#   F - "fix-binary": interpreter fd is pinned at register time and survives chroot.
#
# Registers directly via /proc/sys/fs/binfmt_misc/register because
# `update-binfmts` does not expose the credentials flag.
#
# $1 = qemu target arch (e.g. "arm", "aarch64")
function _binfmt_register_cf() {
  local arch="$1"
  local name="qemu-$arch"
  local entry="/proc/sys/fs/binfmt_misc/$name"
  local spec="/usr/share/binfmts/$name"

  local interp
  interp="$(command -v "qemu-$arch-static")" \
    || { echo "qemu-$arch-static not found in PATH"; return 1; }

  # Make sure binfmt_misc is mounted
  mount | grep -q "type binfmt_misc" || \
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

  # If already registered with both C and F flags, nothing to do.
  # C preserves credentials (suid), F pins the interpreter fd so it
  # survives chroot - both are required for this setup.
  if [ -f "$entry" ] \
     && grep -qE "^flags:.*C" "$entry" \
     && grep -qE "^flags:.*F" "$entry"; then
    echo "binfmt $name already registered with CF flags, skipping."
    return 0
  fi

  # Remove the existing (likely F-only / credentials-no) entry so we can
  # re-register with our flags.
  [ -f "$entry" ] && echo -1 > "$entry"

  # Pull magic/mask from the qemu-user-static spec file shipped by Debian.
  [ -f "$spec" ] || { echo "binfmt spec missing: $spec"; return 1; }
  local magic mask
  magic=$(awk '/^magic / {print $2}' "$spec")
  mask=$(awk  '/^mask / {print $2}'  "$spec")
  [ -n "$magic" ] && [ -n "$mask" ] \
    || { echo "could not parse magic/mask from $spec"; return 1; }

  # Register with CF flags. The kernel parses the \xNN escape sequences
  # in magic/mask itself; we just pass them through verbatim.
  echo "Registering $name -> $interp with flags CF..."
  printf ':%s:M::%s:%s:%s:CF' "$name" "$magic" "$mask" "$interp" \
    > /proc/sys/fs/binfmt_misc/register
}

function prepare_chroot_environment() {
  # When cross-building on a non-matching host, register qemu-user-static via
  # binfmt_misc so the kernel transparently runs foreign-arch binaries in chroot.
  if [ "$EDITBASE_ARCH" == "armv7l" ] && [ "$(arch)" != "armv7l" ]; then
    _binfmt_register_cf arm
  elif [[ "$EDITBASE_ARCH" == "aarch64" || "$EDITBASE_ARCH" == "arm64" ]] \
       && [[ "$(arch)" != "aarch64" && "$(arch)" != "arm64" ]]; then
    _binfmt_register_cf aarch64
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
