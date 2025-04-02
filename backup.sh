#!/bin/bash

# Define the source directory to back up and the backup root directory
SOURCE_DIR="/srv/www"  # Replace with the directory you want to back up
BACKUP_ROOT="/mnt/backup"  # Replace with the root backup directory

# Get the current date and time
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_TIME=$(date +"%H-%M-%S")
CURRENT_WEEK=$(date +"%Y-W%U")
CURRENT_MONTH=$(date +"%Y-%m")
CURRENT_YEAR=$(date +"%Y")

# Create backup directories if they don't exist
mkdir -p "$BACKUP_ROOT/hourly"
mkdir -p "$BACKUP_ROOT/daily"
mkdir -p "$BACKUP_ROOT/weekly"
mkdir -p "$BACKUP_ROOT/monthly"
mkdir -p "$BACKUP_ROOT/yearly"

# Perform backups
# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory $SOURCE_DIR does not exist. Exiting."
    exit 1
fi
# Check if the backup root directory is writable
if [ ! -w "$BACKUP_ROOT" ]; then
    echo "Backup root directory $BACKUP_ROOT is not writable. Exiting."
    exit 1
fi
# Check if the backup directories are writable
if [ ! -w "$BACKUP_ROOT/hourly" ] || [ ! -w "$BACKUP_ROOT/daily" ] || [ ! -w "$BACKUP_ROOT/weekly" ] || [ ! -w "$BACKUP_ROOT/monthly" ] || [ ! -w "$BACKUP_ROOT/yearly" ]; then
    echo "One or more backup directories are not writable. Exiting."
    exit 1
fi
# Hourly backup
tar -czf "$BACKUP_ROOT/hourly/backup-$CURRENT_DATE-$CURRENT_TIME.tar.gz" -C "$SOURCE_DIR" .

# Daily backup (only once per day)
if [ ! -f "$BACKUP_ROOT/daily/backup-$CURRENT_DATE.tar.gz" ]; then
    tar -czf "$BACKUP_ROOT/daily/backup-$CURRENT_DATE.tar.gz" -C "$SOURCE_DIR" .
fi

# Weekly backup (only once per week)
if [ ! -f "$BACKUP_ROOT/weekly/backup-$CURRENT_WEEK.tar.gz" ]; then
    tar -czf "$BACKUP_ROOT/weekly/backup-$CURRENT_WEEK.tar.gz" -C "$SOURCE_DIR" .
fi

# Monthly backup (only once per month)
if [ ! -f "$BACKUP_ROOT/monthly/backup-$CURRENT_MONTH.tar.gz" ]; then
    tar -czf "$BACKUP_ROOT/monthly/backup-$CURRENT_MONTH.tar.gz" -C "$SOURCE_DIR" .
fi

# Yearly backup (only once per year)
if [ ! -f "$BACKUP_ROOT/yearly/backup-$CURRENT_YEAR.tar.gz" ]; then
    tar -czf "$BACKUP_ROOT/yearly/backup-$CURRENT_YEAR.tar.gz" -C "$SOURCE_DIR" .
fi

# Cleanup old backups
# Keep only the last 24 hourly backups
find "$BACKUP_ROOT/hourly" -mindepth 1 -maxdepth 1 -type f | sort | head -n -24 | xargs -r rm -f

# Keep only the last 7 daily backups
find "$BACKUP_ROOT/daily" -mindepth 1 -maxdepth 1 -type f | sort | head -n -7 | xargs -r rm -f

# Keep only the last 52 weekly backups
find "$BACKUP_ROOT/weekly" -mindepth 1 -maxdepth 1 -type f | sort | head -n -52 | xargs -r rm -f

# Keep only the last 24 monthly backups
find "$BACKUP_ROOT/monthly" -mindepth 1 -maxdepth 1 -type f | sort | head -n -24 | xargs -r rm -f

# No limit for yearly backups (no cleanup needed)