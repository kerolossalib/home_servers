FROM adguard/adguardhome:latest

COPY conf/AdGuardHome.yaml /defaults/AdGuardHome.yaml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
