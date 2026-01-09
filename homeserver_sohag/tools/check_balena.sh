#!/usr/bin/env bash
set -euo pipefail

# Quick health script to inspect NAS/Jellyfin mounts on the Balena device.
# Override DEVICE_UUID via env var if needed.
DEVICE_UUID="${DEVICE_UUID:-67d77f362605319ae8c7e2cd0c748e7d}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing command: $1" >&2
    exit 1
  fi
}

require_cmd balena

echo "== Checking env for NAS/Jellyfin on device $DEVICE_UUID =="
balena env list --device "$DEVICE_UUID" --service nas || true
balena env list --device "$DEVICE_UUID" --service jellyfin || true

echo
echo "== Last NAS log lines =="
balena device logs "$DEVICE_UUID" --service nas --tail 50 || true

echo
echo "== Last Jellyfin log lines =="
balena device logs "$DEVICE_UUID" --service jellyfin --tail 50 || true

echo
echo "== NAS mount state inside container =="
balena exec "$DEVICE_UUID" --service nas -- sh -c "mount | grep /share || true; ls -la /share || true" || true

echo
echo "== Jellyfin mount state inside container =="
balena exec "$DEVICE_UUID" --service jellyfin -- sh -c "mount | grep /data/media/net || true; ls -la /data/media/net || true" || true

echo
echo "== Kernel USB hints (host) =="
balena device ssh "$DEVICE_UUID" "dmesg | tail -n 20" || true

