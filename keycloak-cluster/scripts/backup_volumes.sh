#!/bin/bash

# Setup variables
BASE_DIR=$(dirname "$(dirname "$0")")
BACKUP_DIR="${BASE_DIR}/backups/volumes"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/volume_backup_${TIMESTAMP}.tar.gz"
DOCKER_COMPOSE_DIR="${BASE_DIR}/docker-compose"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo "[$(date)] Starting volume backup..."

# Verify Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: docker-compose is not installed or not in PATH"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker service is not running or you don't have permission"
    exit 1
fi

# Stop containers to ensure data consistency
echo "Stopping containers for consistent backup..."
cd ${DOCKER_COMPOSE_DIR}
docker-compose stop

# Backup MySQL data directory
echo "Backing up MySQL data directory..."
tar -czf ${BACKUP_FILE} -C ${BASE_DIR} mysql_data

# Check if backup was successful
if [ $? -eq 0 ]; then
    # Get file size statistics
    FILESIZE=$(du -h ${BACKUP_FILE} | cut -f1)
    echo "Backup completed: ${BACKUP_FILE} (${FILESIZE})"
    
    # Keep only the 3 most recent backups
    echo "Removing old backups..."
    ls -tp ${BACKUP_DIR}/*.tar.gz | grep -v '/$' | tail -n +4 | xargs -I {} rm -- {} 2>/dev/null
    
    echo "[$(date)] Volume backup completed successfully."
else
    echo "[$(date)] Volume backup FAILED!"
    RESTART_FAILED=true
fi

# Restart containers
echo "Restarting containers..."
docker-compose start

# Check if restart was successful
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to restart containers. Manual intervention required!"
    exit 2
fi

# Exit with appropriate status
if [ "${RESTART_FAILED}" = "true" ]; then
    exit 1
fi

exit 0 