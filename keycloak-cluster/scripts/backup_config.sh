#!/bin/bash

# Setup variables
BASE_DIR=$(dirname "$(dirname "$0")")
BACKUP_DIR="${BASE_DIR}/backups/configs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/configs_${TIMESTAMP}.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo "[$(date)] Starting configuration backup..."

# Backup configuration files
tar -czf ${BACKUP_FILE} \
    -C ${BASE_DIR} docker-compose \
    -C ${BASE_DIR} conf.d \
    -C ${BASE_DIR} ssl \
    -C ${BASE_DIR} docker-images/keycloak/Dockerfile \
    -C ${BASE_DIR} docker-images/keycloak/plugins

if [ $? -eq 0 ]; then
    # Get file size statistics
    FILESIZE=$(du -h ${BACKUP_FILE} | cut -f1)
    echo "Backup completed: ${BACKUP_FILE} (${FILESIZE})"
    
    # Keep only the 5 most recent backups
    echo "Removing old backups..."
    ls -tp ${BACKUP_DIR}/*.tar.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {} 2>/dev/null
    
    echo "[$(date)] Configuration backup completed successfully."
else
    echo "[$(date)] Configuration backup FAILED!"
    exit 1
fi 