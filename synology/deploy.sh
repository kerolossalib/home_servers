#!/bin/bash
# deploy.sh - Eseguito dal Synology Task Scheduler
set -e

REPO_DIR="/volume1/docker/home_servers"
SYNOLOGY_DIR="$REPO_DIR/synology"
LOG_FILE="$SYNOLOGY_DIR/deploy.log"

cd "$REPO_DIR" || { echo "[$(date)] ERRORE: $REPO_DIR non trovato" >> "$LOG_FILE"; exit 1; }

BEFORE=$(git rev-parse HEAD)
git pull origin main 2>> "$LOG_FILE" || { echo "[$(date)] ERRORE: git pull fallito" >> "$LOG_FILE"; exit 1; }
AFTER=$(git rev-parse HEAD)

DEPLOY_ALL=false
if [ "$1" = "--all" ]; then
    DEPLOY_ALL=true
elif [ "$BEFORE" = "$AFTER" ] && [ "$DEPLOY_ALL" = false ]; then
    exit 0
fi

echo "[$(date)] $BEFORE -> $AFTER (all=$DEPLOY_ALL)" >> "$LOG_FILE"

CHANGED=$(git diff --name-only "$BEFORE" "$AFTER")

for service in "$SYNOLOGY_DIR"/services/*/; do
    [ -d "$service" ] || continue
    service_name=$(basename "$service")
    if [ "$DEPLOY_ALL" = true ] || echo "$CHANGED" | grep -q "^synology/services/$service_name/"; then
        echo "[$(date)] Deploy $service_name..." >> "$LOG_FILE"
        cd "$service"
        sudo docker-compose pull 2>> "$LOG_FILE"
        sudo docker-compose up -d --remove-orphans 2>> "$LOG_FILE"
        echo "[$(date)] $service_name done" >> "$LOG_FILE"
    fi
done

echo "[$(date)] Deploy completato" >> "$LOG_FILE"
