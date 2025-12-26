#!/bin/sh
set -e

CONFIG_DIR="/opt/adguardhome/conf"
CONFIG_FILE="${CONFIG_DIR}/AdGuardHome.yaml"
DEFAULT_CONFIG="/defaults/AdGuardHome.yaml"

mkdir -p "${CONFIG_DIR}"

if [ "${ADGUARD_CONFIG_OVERWRITE:-1}" = "1" ] || [ ! -f "${CONFIG_FILE}" ]; then
  cp "${DEFAULT_CONFIG}" "${CONFIG_FILE}"
fi

exec /opt/adguardhome/AdGuardHome --no-check-update -c "${CONFIG_FILE}" -w /opt/adguardhome/work
