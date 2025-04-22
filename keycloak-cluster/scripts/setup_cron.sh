#!/bin/bash

# Get the absolute path to the scripts directory
SCRIPTS_DIR=$(dirname "$(realpath "$0")")

# Add backup jobs to crontab
(crontab -l 2>/dev/null || echo "") | grep -v "$(basename "$SCRIPTS_DIR")" > /tmp/current_cron

# Add backup jobs
echo "# MySQL backup - Daily at 2 AM" >> /tmp/current_cron
echo "0 2 * * * ${SCRIPTS_DIR}/backup_mysql.sh >> ${SCRIPTS_DIR}/../backups/backup.log 2>&1" >> /tmp/current_cron
echo "" >> /tmp/current_cron

echo "# Configuration backup - Weekly on Sunday at 3 AM" >> /tmp/current_cron
echo "0 3 * * 0 ${SCRIPTS_DIR}/backup_config.sh >> ${SCRIPTS_DIR}/../backups/backup.log 2>&1" >> /tmp/current_cron
echo "" >> /tmp/current_cron

echo "# Volume backup - Monthly on the 1st at 4 AM" >> /tmp/current_cron
echo "0 4 1 * * ${SCRIPTS_DIR}/backup_volumes.sh >> ${SCRIPTS_DIR}/../backups/backup.log 2>&1" >> /tmp/current_cron

# Install new crontab
crontab /tmp/current_cron
rm /tmp/current_cron

echo "Backup schedule has been configured:"
echo "- MySQL: Daily at 2 AM"
echo "- Configuration: Weekly on Sunday at 3 AM"
echo "- Volumes: Monthly on the 1st at 4 AM"
echo ""
echo "Current crontab:"
crontab -l 