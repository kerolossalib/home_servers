#!/bin/bash
set -e

REPO_DIR="/volume1/docker/home_servers"
SYNOLOGY_DIR="$REPO_DIR/synology"

echo "=== Pull ultima versione da Git ==="
cd "$REPO_DIR"
git pull origin main

echo "=== Redeploy di TUTTI i servizi ==="
for service in "$SYNOLOGY_DIR"/services/*/; do
    [ -d "$service" ] || continue
    service_name=$(basename "$service")
    echo "--- $service_name ---"
    cd "$service"
    sudo docker-compose pull
    sudo docker-compose up -d --remove-orphans
    echo "--- $service_name done ---"
done

echo "=== Fatto! ==="
