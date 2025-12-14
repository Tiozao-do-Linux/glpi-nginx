#!/bin/bash

# This script performs a complete backup of the GLPI setup defined in docker-compose.yml,
# following Docker best practices. It dumps the database and backs up all named volumes.
# Assumptions:
# - docker and docker-compose are installed.
# - The script is run from the same directory as docker-compose.yml.
# - A .env file exists if custom environment variables are used (optional, but recommended for passwords).
# - Backups are stored in a timestamped directory under ./backups/.
# - Database backup uses mariadb-dump for consistency (instead of copying volume files).
# - File volumes are backed up using tar archives while containers are running.
# - To restore, you would recreate volumes from tar and import the DB dump.

set -e

# Source .env if it exists (for environment variables like DB_USER, but not required since we use container env)
if [ -f .env ]; then
    source .env
fi

# Determine the Compose project name (default to directory name)
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename "$(pwd)")}"

# Backup directory
BACKUP_DIR="./backups/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$BACKUP_DIR"

echo "Starting backup to $BACKUP_DIR..."

# Step 1: Database dump (using mariadb-dump for safe, consistent backup)
echo "Dumping database..."
docker compose exec -T database sh -c "mariadb-dump -u \$MARIADB_USER --password=\$MARIADB_PASSWORD \$MARIADB_DATABASE" | gzip > "$BACKUP_DIR/db_dump.sql.gz"
echo "Database dump completed."

# Step 2: Backup named volumes (file-based data)
# Volumes: glpi_php, glpi-config, glpi-files, glpi-marketplace, glpi-plugins, glpi_database
# Note: We back up glpi_database volume files as well, but prefer the dump for restore.
# Use busybox for lightweight tar creation.
VOLUMES=("glpi-config" "glpi-files" "glpi-marketplace" "glpi-plugins" "glpi_database" "glpi_php")

for VOLUME in "${VOLUMES[@]}"; do
    FULL_VOLUME_NAME="${COMPOSE_PROJECT_NAME}_${VOLUME}"
    echo "Backing up volume: $FULL_VOLUME_NAME"
    docker run --rm \
        -v "${FULL_VOLUME_NAME}:/volume" \
        -v "$(pwd)/${BACKUP_DIR}:/backup" \
        busybox \
        tar czf "/backup/${VOLUME}.tar.gz" -C /volume ./
    echo "Volume $FULL_VOLUME_NAME backed up."
done

# Step 3: Backup host-mounted configuration files (if they exist)
echo "Backing up host configuration files..."
HOST_FILES=("custom-php.ini" "info.php" "custom-nginx.conf" "nginx.crt" "nginx.key" ".env" "docker-compose.yml")

for FILE in "${HOST_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        cp "$FILE" "$BACKUP_DIR/"
        echo "Backed up $FILE"
    fi
done

echo "Backup completed successfully. Files are in $BACKUP_DIR."
