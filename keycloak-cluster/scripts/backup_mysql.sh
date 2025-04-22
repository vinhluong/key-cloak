#!/bin/bash

# Load environment variables
source "$(dirname "$0")/../docker-compose/.env"

# Setup variables
BACKUP_DIR="$(dirname "$0")/../backups/mysql"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/mysql_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo "[$(date)] Starting MySQL backup..."

# Perform MySQL backup
echo "Dumping MySQL databases..."
docker exec mysql-container /usr/bin/mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > ${BACKUP_FILE}

# Check result
if [ $? -eq 0 ]; then
    # Compress backup file
    echo "Compressing backup file..."
    gzip ${BACKUP_FILE}
    
    # Get file size statistics
    FILESIZE=$(du -h ${BACKUP_FILE}.gz | cut -f1)
    echo "Backup completed: ${BACKUP_FILE}.gz (${FILESIZE})"
    
    # Keep only the 7 most recent backups
    echo "Removing old backups..."
    ls -tp ${BACKUP_DIR}/*.gz | grep -v '/$' | tail -n +8 | xargs -I {} rm -- {} 2>/dev/null
    
    echo "[$(date)] MySQL backup completed successfully."
else
    echo "[$(date)] MySQL backup FAILED!"
    exit 1
fi 