#!/bin/bash

# Load environment variables
source "$(dirname "$0")/../docker-compose/.env"

# Setup variables
BACKUP_DIR="$(dirname "$0")/../backups/mysql"
DOCKER_COMPOSE_DIR="$(dirname "$0")/../docker-compose"
RESTORE_FILE=""

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Restore MySQL database from backup"
    echo
    echo "Options:"
    echo "  -f, --file FILENAME   Specific backup file to restore"
    echo "  -l, --list            List available backup files"
    echo "  -h, --help            Display this help message"
    echo
    exit 1
}

# Function to list backup files
list_backups() {
    echo "Available MySQL backups:"
    if [ -d "${BACKUP_DIR}" ]; then
        if [ "$(ls -A ${BACKUP_DIR})" ]; then
            ls -lt ${BACKUP_DIR}/*.gz | awk '{print NR":", $9, "("$5")", $6, $7, $8}'
        else
            echo "No backup files found in ${BACKUP_DIR}"
        fi
    else
        echo "Backup directory not found: ${BACKUP_DIR}"
    fi
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            RESTORE_FILE="$2"
            shift 2
            ;;
        -l|--list)
            list_backups
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# If no file specified, use the most recent backup
if [ -z "${RESTORE_FILE}" ]; then
    RESTORE_FILE=$(ls -t ${BACKUP_DIR}/*.gz 2>/dev/null | head -1)
    if [ -z "${RESTORE_FILE}" ]; then
        echo "ERROR: No backup files found in ${BACKUP_DIR}"
        exit 1
    fi
    echo "Using most recent backup: ${RESTORE_FILE}"
fi

# Check if the backup file exists
if [ ! -f "${RESTORE_FILE}" ]; then
    echo "ERROR: Backup file does not exist: ${RESTORE_FILE}"
    exit 1
fi

# Get confirmation from user
echo "WARNING: This will overwrite the current MySQL database."
read -p "Do you want to continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Stop the Keycloak services
echo "Stopping Keycloak services..."
cd ${DOCKER_COMPOSE_DIR}
docker-compose stop keycloak1 keycloak2

# Create temporary file for restoring
TMP_SQL="/tmp/mysql_restore_$(date +%s).sql"

# Uncompress the backup
echo "Decompressing backup file..."
gunzip -c "${RESTORE_FILE}" > "${TMP_SQL}"

# Restore the database
echo "Restoring MySQL database..."
docker exec -i mysql-container mysql -u root -p${MYSQL_ROOT_PASSWORD} < "${TMP_SQL}"

# Check the restore result
if [ $? -eq 0 ]; then
    echo "Database successfully restored from ${RESTORE_FILE}"
    # Clean up
    echo "Cleaning up temporary files..."
    rm -f "${TMP_SQL}"
else
    echo "ERROR: Failed to restore the database"
    rm -f "${TMP_SQL}"
    # Start Keycloak again even if restore failed
    docker-compose start keycloak1 keycloak2
    exit 1
fi

# Restart Keycloak services
echo "Restarting Keycloak services..."
docker-compose start keycloak1 keycloak2

echo "Restore completed successfully." 