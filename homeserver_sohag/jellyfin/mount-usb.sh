#!/bin/sh
set -eu

log() {
  echo "[jellyfin-mount] $*"
}

MOUNT_POINT="${USB_MOUNT_POINT:-/data/media/usb}"
DEVICE="${USB_DEVICE:-}"
DEVICE_GLOB="${USB_DEVICE_GLOB:-/dev/sd*1}"
POLL_INTERVAL="${USB_POLL_INTERVAL:-5}"

NET_TYPE="${NET_SHARE_TYPE:-}"
NET_HOST="${NET_SHARE_HOST:-}"
NET_PATH="${NET_SHARE_PATH:-}"
NET_USER="${NET_SHARE_USER:-}"
NET_PASS="${NET_SHARE_PASS:-}"
NET_DOMAIN="${NET_SHARE_DOMAIN:-}"
NET_OPTS="${NET_SHARE_OPTS:-}"
NET_MOUNT_POINT="${NET_SHARE_MOUNT_POINT:-/data/media/net}"

mkdir -p "$MOUNT_POINT"
mkdir -p "$NET_MOUNT_POINT"

is_mounted() {
  grep -q " $1 " /proc/mounts
}

find_device() {
  if [ -n "$DEVICE" ]; then
    if [ -b "$DEVICE" ]; then
      echo "$DEVICE"
      return 0
    fi
    return 1
  fi

  for dev in $DEVICE_GLOB; do
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

  log "attempting to mount USB $dev at $MOUNT_POINT"
  if mount "$dev" "$MOUNT_POINT"; then
    log "mounted USB $dev at $MOUNT_POINT"
    return 0
  fi

  log "mount failed for $dev"
  return 1
}

try_mount_net() {
  if [ -z "$NET_TYPE" ]; then
    return 0
  fi

  if [ -z "$NET_HOST" ] || [ -z "$NET_PATH" ]; then
    log "network share requires NET_SHARE_HOST and NET_SHARE_PATH"
    return 1
  fi

  if [ "$NET_TYPE" = "smb" ]; then
    share="${NET_PATH#/}"
    src="//$NET_HOST/$share"
    if [ -n "$NET_USER" ]; then
      creds="username=$NET_USER,password=$NET_PASS"
    else
      creds="guest"
    fi
    if [ -n "$NET_DOMAIN" ]; then
      creds="$creds,domain=$NET_DOMAIN"
    fi
    if [ -n "$NET_OPTS" ]; then
      opts="$creds,$NET_OPTS"
    else
      opts="$creds,vers=3.0,iocharset=utf8"
    fi
    log "attempting to mount SMB $src at $NET_MOUNT_POINT"
    mount -t cifs -o "$opts" "$src" "$NET_MOUNT_POINT" || return 1
    log "mounted SMB $src at $NET_MOUNT_POINT"
    return 0
  fi

  if [ "$NET_TYPE" = "nfs" ]; then
    src="$NET_HOST:$NET_PATH"
    log "attempting to mount NFS $src at $NET_MOUNT_POINT"
    if [ -n "$NET_OPTS" ]; then
      mount -t nfs -o "$NET_OPTS" "$src" "$NET_MOUNT_POINT" || return 1
    else
      mount -t nfs "$src" "$NET_MOUNT_POINT" || return 1
    fi
    log "mounted NFS $src at $NET_MOUNT_POINT"
    return 0
  fi

  log "unknown NET_SHARE_TYPE '$NET_TYPE' (use smb or nfs)"
  return 1
}

mount_loop() {
  while true; do
    if ! is_mounted "$MOUNT_POINT"; then
      try_mount_usb || true
    fi
    if [ -n "$NET_TYPE" ] && ! is_mounted "$NET_MOUNT_POINT"; then
      try_mount_net || true
    fi
    sleep "$POLL_INTERVAL"
  done
}

mount_loop &

if [ -x /jellyfin/jellyfin ]; then
  exec /jellyfin/jellyfin "$@"
fi

if [ -x /init ]; then
  exec /init "$@"
fi

log "no known entrypoint found; sleeping"
tail -f /dev/null
