# Why make backups?

You make backups to protect against data loss from hardware failure, accidental deletion, viruses, theft, or disasters, ensuring you can restore critical files, maintain business continuity, save time and money, and meet legal compliance, ultimately providing peace of mind.

# What to back up in GLPI

* Database (using mariadb-dump for secure and consistent backup) generating a dump in SQL format.

* named volumes (file-based data)
    1. glpi-config
    1. glpi-files
    1. glpi-marketplace
    1. glpi-plugins
    1. glpi_database (Faster to back up, but inconsistencies in the files may occur)
    1. glpi_php (It's really not necessary. It will always be created with the image files.)


# Example
```
# ./complete-backup.sh 
Starting backup to ./backups/2025-12-14_11-35-23...
Dumping database...
Database dump completed.
Backing up volume: glpi-nginx_glpi-config
Volume glpi-nginx_glpi-config backed up.
Backing up volume: glpi-nginx_glpi-files
Volume glpi-nginx_glpi-files backed up.
Backing up volume: glpi-nginx_glpi-marketplace
Volume glpi-nginx_glpi-marketplace backed up.
Backing up volume: glpi-nginx_glpi-plugins
Volume glpi-nginx_glpi-plugins backed up.
Backing up volume: glpi-nginx_glpi_database
Volume glpi-nginx_glpi_database backed up.
Backing up volume: glpi-nginx_glpi_php
Volume glpi-nginx_glpi_php backed up.
Backing up host configuration files...
Backed up custom-php.ini
Backed up info.php
Backed up custom-nginx.conf
Backed up nginx.crt
Backed up nginx.key
Backed up .env
Backed up docker-compose.yml
Backup completed successfully. Files are in ./backups/2025-12-14_11-35-23.

# ls -l ./backups/2025-12-14_11-35-23/
total 92432
-rw-rw-r-- 1 jarbelix jarbelix     1769 dez 14 11:35 custom-nginx.conf
-rw-rw-r-- 1 jarbelix jarbelix     2151 dez 14 11:35 custom-php.ini
-rw-rw-r-- 1 jarbelix jarbelix   114898 dez 14 11:35 db_dump.sql.gz
-rw-rw-r-- 1 jarbelix jarbelix     1851 dez 14 11:35 docker-compose.yml
-rw-r--r-- 1 root     root         2103 dez 14 11:35 glpi-config.tar.gz
-rw-r--r-- 1 root     root      5577639 dez 14 11:35 glpi_database.tar.gz
-rw-r--r-- 1 root     root       413724 dez 14 11:35 glpi-files.tar.gz
-rw-r--r-- 1 root     root           86 dez 14 11:35 glpi-marketplace.tar.gz
-rw-r--r-- 1 root     root     88495028 dez 14 11:35 glpi_php.tar.gz
-rw-r--r-- 1 root     root           89 dez 14 11:35 glpi-plugins.tar.gz
-rw-rw-r-- 1 jarbelix jarbelix       16 dez 14 11:35 info.php
-rw-rw-r-- 1 jarbelix jarbelix     1294 dez 14 11:35 nginx.crt
-rw-rw-r-- 1 jarbelix jarbelix     1704 dez 14 11:35 nginx.key

```

# Backup Automation Tip

Create a cron job entry according to your backup policy.

# TO restore

- Recreate volumes: docker volume create for each, then untar into them using similar docker run.
- Import DB: docker compose exec database sh -c 'mysql -u $MARIADB_USER --password=$MARIADB_PASSWORD $MARIADB_DATABASE' < db_dump.sql