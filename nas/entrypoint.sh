#!/bin/sh
set -eu

log() {
  echo "[nas] $*"
}

NAS_USER="${NAS_USER:-nas}"
NAS_PASS="${NAS_PASS:-}"
NAS_SHARE_NAME="${NAS_SHARE_NAME:-NAS}"
NAS_WORKGROUP="${NAS_WORKGROUP:-WORKGROUP}"
NAS_SERVER_NAME="${NAS_SERVER_NAME:-balena-nas}"

USB_MOUNT_POINT="${USB_MOUNT_POINT:-/share}"
USB_DEVICE="${USB_DEVICE:-}"
USB_DEVICE_GLOB="${USB_DEVICE_GLOB:-/dev/sd*2}"
USB_POLL_INTERVAL="${USB_POLL_INTERVAL:-5}"

if [ -z "$NAS_PASS" ]; then
  log "NAS_PASS is not set; refusing to start"
  exit 1
fi

mkdir -p "$USB_MOUNT_POINT"

if ! id "$NAS_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$NAS_USER"
fi

echo "$NAS_USER:$NAS_PASS" | chpasswd
printf '%s\n%s\n' "$NAS_PASS" "$NAS_PASS" | smbpasswd -a -s "$NAS_USER" >/dev/null

export NAS_USER NAS_SHARE_NAME NAS_WORKGROUP NAS_SERVER_NAME
envsubst < /etc/samba/smb.conf.template > /etc/samba/smb.conf

is_mounted() {
  grep -q " $1 " /proc/mounts
}

find_device() {
  if [ -n "$USB_DEVICE" ]; then
    if [ -b "$USB_DEVICE" ]; then
      echo "$USB_DEVICE"
      return 0
    fi
    return 1
  fi

  for dev in $USB_DEVICE_GLOB; do
    if [ -b "$dev" ]; then
      echo "$dev"
      return 0
    fi
  done
  return 1
}

try_mount_usb() {
  dev="$(find_device || true)"
  if [ -z "$dev" ]; then
    log "no USB block device found yet"
    return 1
  fi

  log "attempting to mount USB $dev at $USB_MOUNT_POINT"
  if mount "$dev" "$USB_MOUNT_POINT"; then
    log "mounted USB $dev at $USB_MOUNT_POINT"
    return 0
  fi

  log "mount failed for $dev"
  return 1
}

mount_loop() {
  while true; do
    if ! is_mounted "$USB_MOUNT_POINT"; then
      try_mount_usb || true
    fi
    sleep "$USB_POLL_INTERVAL"
  done
}

mount_loop &

exec smbd -F --no-process-group
