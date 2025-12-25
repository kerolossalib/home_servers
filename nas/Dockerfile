FROM debian:bookworm-slim

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends samba exfatprogs gettext-base; \
  rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY smb.conf.template /etc/samba/smb.conf.template

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 445

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
