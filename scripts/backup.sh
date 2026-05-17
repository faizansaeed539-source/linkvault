#!/bin/bash

# ============================================
# LinkVault Database Backup Script
# Backs up PostgreSQL, compresses, rotates
# ============================================

# --- Config ---
DB_NAME="linkvault"
DB_USER="linkvault_user"
BACKUP_DIR="$HOME/linkvault/backups"
LOG_FILE="$HOME/linkvault/scripts/backup.log"
KEEP_DAYS=7

# --- Setup ---
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/linkvault_$TIMESTAMP.sql.gz"

# --- Logging function ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --- Start ---
log "========== Backup started =========="

# --- Dump & compress database ---
log "Dumping database: $DB_NAME"
if PGPASSWORD="devpassword" pg_dump -U "$DB_USER" -h localhost "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    log "Backup successful: $BACKUP_FILE (size: $SIZE)"
else
    log "ERROR: Backup failed!"
    exit 1
fi

# --- Rotate old backups (delete anything older than 7 days) ---
log "Rotating backups older than $KEEP_DAYS days..."
DELETED=$(find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$KEEP_DAYS -print -delete | wc -l)
log "Deleted $DELETED old backup(s)"

# --- Summary ---
TOTAL=$(find "$BACKUP_DIR" -name "*.sql.gz" | wc -l)
log "Total backups stored: $TOTAL"
log "========== Backup complete =========="
