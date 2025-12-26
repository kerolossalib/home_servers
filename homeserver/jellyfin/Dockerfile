FROM jellyfin/jellyfin:latest

RUN set -eux; \
  if command -v apt-get >/dev/null 2>&1; then \
    apt-get update; \
    apt-get install -y --no-install-recommends cifs-utils nfs-common; \
    rm -rf /var/lib/apt/lists/*; \
  elif command -v apk >/dev/null 2>&1; then \
    apk add --no-cache cifs-utils nfs-utils; \
  else \
    echo "No supported package manager found for SMB/NFS tools" >&2; \
    exit 1; \
  fi

COPY mount-usb.sh /usr/local/bin/mount-usb.sh
RUN chmod +x /usr/local/bin/mount-usb.sh

ENTRYPOINT ["/usr/local/bin/mount-usb.sh"]
