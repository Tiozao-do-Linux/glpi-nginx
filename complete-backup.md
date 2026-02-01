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
$ ./complete-backup.sh 
Starting backup to ./backups/2026-02-01_15-21-17...
Dumping database...
Database dump completed.
Backing up volume: glpi-nginx_glpi-config
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
61dfb50712f5: Pull complete 
Digest: sha256:e226d6308690dbe282443c8c7e57365c96b5228f0fe7f40731b5d84d37a06839
Status: Downloaded newer image for busybox:latest
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
Backup completed successfully. Files are in ./backups/2026-02-01_15-21-17.

$ ls -l ./backups/2026-02-01_15-21-17/
total 5864
-rw-rw-r-- 1 jarbelix jarbelix    1899 fev  1 15:21 custom-nginx.conf
-rw-rw-r-- 1 jarbelix jarbelix    2371 fev  1 15:21 custom-php.ini
-rw-rw-r-- 1 jarbelix jarbelix  119875 fev  1 15:21 db_dump.sql.gz
-rw-rw-r-- 1 jarbelix jarbelix    1750 fev  1 15:21 docker-compose.yml
-rw-r--r-- 1 root     root          85 fev  1 15:21 glpi-config.tar.gz
-rw-r--r-- 1 root     root     5835185 fev  1 15:21 glpi_database.tar.gz
-rw-r--r-- 1 root     root          85 fev  1 15:21 glpi-files.tar.gz
-rw-r--r-- 1 root     root          85 fev  1 15:21 glpi-marketplace.tar.gz
-rw-r--r-- 1 root     root          87 fev  1 15:21 glpi_php.tar.gz
-rw-r--r-- 1 root     root          85 fev  1 15:21 glpi-plugins.tar.gz
-rw-rw-r-- 1 jarbelix jarbelix      16 fev  1 15:21 info.php
-rw-rw-r-- 1 jarbelix jarbelix    1294 fev  1 15:21 nginx.crt
-rw-rw-r-- 1 jarbelix jarbelix    1704 fev  1 15:21 nginx.key
```

# Backup Automation Tip

Create a cron job entry according to your backup policy.

# TO restore

- Recreate volumes: docker volume create for each, then untar into them using similar docker run.
- Import DB: docker compose exec database sh -c 'mysql -u $MARIADB_USER --password=$MARIADB_PASSWORD $MARIADB_DATABASE' < db_dump.sql