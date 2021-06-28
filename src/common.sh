#!/usr/bin/env bash
# based on common.sh from CustomPiOS by Guy Sheffer <guy at gmail dot com>

## Script helpers

function is_installed(){
  # Checks if a package is installed, returns 1 if installed and 0 if not.
  # Usage: is_installed <package_name>
  dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed"
}

function is_in_apt(){
  # Checks if a package is in the apt repo, returns 1 if exists and 0 if not
  # Usage is_in_apt <package_name>
  if [ $(apt-cache policy $1 |  wc  | awk '{print $1}') -gt 0 ]; then
    echo 1
  else
    echo 0
  fi
}

function remove_if_installed(){
  # Removes packages if they are installed
  # Usage: remove_if_installed package1 package2 ...
  remove_extra_list=""
  for package in "$1"
  do
    if [ $( is_installed package ) -eq 1 ];
    then
        remove_extra_list="$remove_extra_list $package"
    fi
  done
  echo $remove_extra_list
}

function systemctl_if_exists() {
    if hash systemctl 2>/dev/null; then
        systemctl "$@"
    else
        echo "no systemctl, not running"
    fi
}

function unpack() {
  # Copy all files & folders from source to target, preserving mode and timestamps
  # and chown to user. If user is not provided, no chown will be performed.
  # Usage: unpack /path/to/source /target user

  from=$1
  to=$2
  owner=
  if [ "$#" -gt 2 ]
  then
    owner=$3
  fi
  mkdir -p /tmp/unpack/
  # $from/. may look funny, but does exactly what we want, copy _contents_
  # from $from to $to, but not $from itself, without the need to glob -- see 
  # http://stackoverflow.com/a/4645159/2028598
  cp -v -r --preserve=mode,timestamps $from/. /tmp/unpack/
  
  if [ -n "$owner" ]
  then
    chown -hR $owner:$owner /tmp/unpack/
  fi

  cp -v -r --preserve=mode,ownership,timestamps /tmp/unpack/. $to
  rm -r /tmp/unpack

}

## Build helpers

function die () {
    echo >&2 "$@"
    exit 1
}

function fixLd(){
    if [ -f etc/ld.so.preload ]; then
        sed -i 's@/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so@\#/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so@' etc/ld.so.preload
        sed -i 's@/usr/lib/arm-linux-gnueabihf/libarmmem.so@\#/usr/lib/arm-linux-gnueabihf/libarmmem.so@' etc/ld.so.preload
  
        # Debian Buster/ Raspbian 2019-06-20
        sed -i 's@/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so@#/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so@' etc/ld.so.preload
   fi
}

function restoreLd(){
    if [ -f etc/ld.so.preload ]; then
        sed -i 's@\#/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so@/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so@' etc/ld.so.preload
        sed -i 's@\#/usr/lib/arm-linux-gnueabihf/libarmmem.so@/usr/lib/arm-linux-gnueabihf/libarmmem.so@' etc/ld.so.preload
  
        # Debian Buster/ Raspbian 2019-06-20
        sed -i 's@#/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so@/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so@' etc/ld.so.preload
    fi
}

function detach_all_loopback(){
  # Cleans up mounted loopback devices from the image name
  # NOTE: it might need a better way to grep for the image name, its might clash with other builds
  for img in $(losetup  | grep $1 | awk '{ print $1 }' );  do
    losetup -d $img
  done
}

function test_for_image(){
  if [ ! -f "$1" ]; then
    echo "Warning, can't see image file: $image"
  fi
}

function mount_image() {
  image_path=$1
  root_partition=$2
  mount_path=$3
  echo $2

  # dump the partition table, locate boot partition and root partition
  boot_partition=1
  fdisk_output=$(sfdisk -d $image_path)
  boot_offset=$(($(echo "$fdisk_output" | grep "$image_path$boot_partition" | awk '{print $4-0}') * 512))
  root_offset=$(($(echo "$fdisk_output" | grep "$image_path$root_partition" | awk '{print $4-0}') * 512))

  echo "Mounting image $image_path on $mount_path, offset for boot partition is $boot_offset, offset for root partition is $root_offset"

  # mount root and boot partition
  
  detach_all_loopback $image_path
  sudo losetup -f
  sudo mount -o loop,offset=$root_offset $image_path $mount_path/
  if [[ "$boot_partition" != "$root_partition" ]]; then
	  sudo losetup -f
	  sudo mount -o loop,offset=$boot_offset,sizelimit=$( expr $root_offset - $boot_offset ) $image_path $mount_path/boot
  fi
  sudo mkdir -p $mount_path/dev/pts
  sudo mount -o bind /dev $mount_path/dev
  sudo mount -o bind /dev/pts $mount_path/dev/pts
}

function unmount_image() {
  mount_path=$1
  force=
  if [ "$#" -gt 1 ]
  then
    force=$2
  fi

  if [ -n "$force" ]
  then
    for process in $(sudo lsof $mount_path | awk '{print $2}')
    do
      echo "Killing process id $process..."
      sudo kill -9 $process
    done
  fi

  # Unmount everything that is mounted
  # 
  # We might have "broken" mounts in the mix that point at a deleted image (in case of some odd
  # build errors). So our "sudo mount" output can look like this:
  #
  #     /path/to/our/image.img (deleted) on /path/to/our/mount type ext4 (rw)
  #     /path/to/our/image.img on /path/to/our/mount type ext4 (rw)
  #     /path/to/our/image.img on /path/to/our/mount/boot type vfat (rw)
  #
  # so we split on "on" first, then do a whitespace split to get the actual mounted directory.
  # Also we sort in reverse to get the deepest mounts first.
  for m in $(sudo mount | grep $mount_path | awk -F " on " '{print $2}' | awk '{print $1}' | sort -r)
  do
    echo "Unmounting $m..."
    sudo umount $m
  done
}

function cleanup() {
    # make sure that all child processed die when we die
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids && sleep 5 && kill -9 $pids
}

function install_fail_on_error_trap() {
  # unmounts image, logs PRINT FAILED to log & console on error
  set -e
  trap 'echo_red "edit failed, unmounting image..." && cd $DIST_PATH && ( unmount_image $EDITBASE_MOUNT_PATH force || true ) && echo_red -e "\nEDIT FAILED!\n"' ERR
}

function install_chroot_fail_on_error_trap() {
  # logs PRINT FAILED to log & console on error
  set -e
  trap 'echo_red -e "\nEDIT FAILED!\n"' ERR
}

function install_cleanup_trap() {
  # kills all child processes of the current process on SIGINT or SIGTERM
  set -e
  trap 'cleanup' SIGINT SIGTERM
 }

function enlarge_ext() {
  # call like this: enlarge_ext /path/to/image partition size
  #
  # will enlarge partition number <partition> on /path/to/image by <size> MB
  image=$1
  partition=$2
  size=$3

  echo "Adding $size MB to partition $partition of $image"
  start=$(sfdisk -d $image | grep "$image$partition" | awk '{print $4-0}')
  offset=$(($start*512))
  dd if=/dev/zero bs=1M count=$size >> $image
  fdisk $image <<FDISK
p
d
$partition
n
p
$partition
$start

p
w
FDISK
  detach_all_loopback $image
  test_for_image $image
  LODEV=$(losetup -f --show -o $offset $image)
  trap 'losetup -d $LODEV' EXIT

  e2fsck -fy $LODEV
  resize2fs -p $LODEV
  losetup -d $LODEV

  trap - EXIT
  echo "Resized partition $partition of $image to +$size MB"
}

function shrink_ext() {
  # call like this: shrink_ext /path/to/image partition size
  #
  # will shrink partition number <partition> on /path/to/image to <size> MB
  image=$1
  partition=$2
  size=$3
  
  echo "Resizing file system to $size MB..."
  start=$(sfdisk -d $image | grep "$image$partition" | awk '{print $4-0}')
  offset=$(($start*512))

  detach_all_loopback $image
  test_for_image $image
  LODEV=$(losetup -f --show -o $offset $image)
  trap 'losetup -d $LODEV' EXIT

  e2fsck -fy $LODEV
  
  e2ftarget_bytes=$(($size * 1024 * 1024))
  e2ftarget_blocks=$(($e2ftarget_bytes / 512 + 1))

  echo "Resizing file system to $e2ftarget_blocks blocks..."
  resize2fs $LODEV ${e2ftarget_blocks}s
  losetup -d $LODEV
  trap - EXIT

  new_end=$(($start + $e2ftarget_blocks))

  echo "Resizing partition to end at $start + $e2ftarget_blocks = $new_end blocks..."
  fdisk $image <<FDISK
p
d
$partition
n
p
$partition
$start
$new_end
p
w
FDISK

  new_size=$((($new_end + 1) * 512))
  echo "Truncating image to $new_size bytes..."
  truncate --size=$new_size $image
  fdisk -l $image

  echo "Resizing filesystem ..."
  detach_all_loopback $image
  test_for_image $image
  LODEV=$(losetup -f --show -o $offset $image)
  trap 'losetup -d $LODEV' EXIT

  e2fsck -fy $LODEV
  resize2fs -p $LODEV
  losetup -d $LODEV
  trap - EXIT
}

function minimize_ext() {
  image=$1
  partition=$2
  buffer=$3

  echo "Resizing partition $partition on $image to minimal size + $buffer MB"
  partitioninfo=$(sfdisk -d $image | grep "$image$partition")
  
  start=$(echo $partitioninfo | awk '{print $4-0}')
  e2fsize_blocks=$(echo $partitioninfo | awk '{print $6-0}')
  offset=$(($start*512))

  detach_all_loopback $image
  test_for_image $image
  LODEV=$(losetup -f --show -o $offset $image)
  trap 'losetup -d $LODEV' EXIT

  e2fsck -fy $LODEV
  e2fblocksize=$(tune2fs -l $LODEV | grep -i "block size" | awk -F: '{print $2-0}')
  e2fminsize=$(resize2fs -P $LODEV 2>/dev/null | grep -i "minimum size" | awk -F: '{print $2-0}')

  e2fminsize_bytes=$(($e2fminsize * $e2fblocksize))
  e2ftarget_bytes=$(($buffer * 1024 * 1024 + $e2fminsize_bytes))
  e2fsize_bytes=$((($e2fsize_blocks - 1) * 512))

  e2fminsize_mb=$(($e2fminsize_bytes / 1024 / 1024))
  e2fminsize_blocks=$(($e2fminsize_bytes / 512 + 1))
  e2ftarget_mb=$(($e2ftarget_bytes / 1024 / 1024))
  e2ftarget_blocks=$(($e2ftarget_bytes / 512 + 1))
  e2fsize_mb=$(($e2fsize_bytes / 1024 / 1024))
  
  size_offset_mb=$(($e2fsize_mb - $e2ftarget_mb))
  
  losetup -d $LODEV

  echo "Actual size is $e2fsize_mb MB ($e2fsize_blocks blocks), Minimum size is $e2fminsize_mb MB ($e2fminsize file system blocks, $e2fminsize_blocks blocks)"
  echo "Resizing to $e2ftarget_mb MB ($e2ftarget_blocks blocks)" 
  
  if [ $size_offset_mb -gt 0 ]; then
	echo "Partition size is bigger then the desired size, shrinking"
	shrink_ext $image $partition $(($e2ftarget_mb - 1)) # -1 to compensat rounding mistakes
  elif [ $size_offset_mb -lt 0 ]; then
    echo "Partition size is lower then the desired size, enlarging"
	enlarge_ext $image $partition $((-$size_offset_mb + 1)) # +1 to compensat rounding mistakes
  fi
}

### Both script and build helpers

function pause() {
  # Pause until Enter is pressed, displaying provided message
  read -p "$*"
}

function echo_red() {
  # Echo text in red
  echo -e -n "\e[91m"
  echo $@
  echo -e -n "\e[0m"
}

function echo_green() {
  # Echo text in green
  echo -e -n "\e[92m"
  echo $@
  echo -e -n "\e[0m"
}

