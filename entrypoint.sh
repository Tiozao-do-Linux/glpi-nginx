#!/bin/bash
set -e -u -o pipefail

function echo_line {
    echo ''
    echo '/------------------------------------------------------------------------------\'
    echo "| $@"
    echo '\------------------------------------------------------------------------------/'
}

cat << '_EOF_'
 ____________________________________________________________________________
/\                                                                           \
\_|         PHP-FPM - https://github.com/Tiozao-do-Linux/glpi-nginx          |
  |   _______________________________________________________________________|_
   \_/_________________________________________________________________________/

_EOF_

if ! [ -f "/etc/php-fpm.conf" -a -f "/etc/php-fpm.d/www.conf" ]; then
    echo_line "PHP-FPM configuration files (/etc/php-fpm.conf or /etc/php-fpm.d/www.conf) not found!"
    exit 1
fi

# echo_line "Show PHP Version"
# php -v

# echo_line "PHP Loaded Modules"
# FORMATTED=$(php -m | awk '/^\[/{if(NR>1)print prev; prev=$0; next}{gsub(/^\s+|\s+$/,""); if($0) prev=prev" "$0} END{print prev}')
# echo "$FORMATTED"

# Create root data directory of persistent files
mkdir -p ${GLPI_DATA_DIR}/{config,files,logs,marketplace}

# # Set proper permissions
# chmod -R g+s ${GLPI_DATA_DIR}

# Create data subdirectory inside files directory
mkdir -p ${GLPI_DATA_DIR}/files/{_cache,_cron,_dumps,_graphs,_inventories,_locales,_lock,_pictures,_plugins,_rss,_sessions,_themes,_tmp,_uploads}

# Adjust permissions - https://glpi-install.readthedocs.io/en/latest/install/
chown -R ${GLPI_USER}:${GLPI_GROUP} ${GLPI_DATA_DIR}

# echo_line "PHP-FPM Configuration Test"
# php-fpm -t

echo_line "Wait 10 seconds for the database to be ready..."
sleep 10

BIN_CONSOLE="php bin/console"

if ! $BIN_CONSOLE system:check_requirements --quiet
then
    echo_line "Requirements not met! Exiting...";
    exit 1
fi

if [ -f "${GLPI_CONFIG_DIR}/config_db.php" ]; then
    $BIN_CONSOLE db:check --quiet
    # GLPI error code for db:check command:
    # 0: Everything is ok
    # 1-4: Warnings related to sql diffs (not critical)
    # 5: Database connection error
    # 6: version cannot be found
    # 7: no tables found
    # if the command above return an error below 5, GLPI is ok
    if ! [ $? -lt 5 ]; then
        echo_line "Database connection error! Exiting...";
        exit 1
    fi
else
    if [ $GLPI_AUTO_INSTALL ]; then
        echo_line "GLPI is not configured yet. Performing CLI installation. Please wait..."
        $BIN_CONSOLE database:install \
        --default-language="$GLPI_LANG" \
        --db-host="$GLPI_DB_HOST" \
        --db-port="$GLPI_DB_PORT" \
        --db-name="$GLPI_DB_NAME" \
        --db-user="$GLPI_DB_USER" \
        --db-password="$GLPI_DB_PASSWORD" \
        --no-interaction --quiet
    else
        echo_line "GLPI is not configured yet. Please use wizard at https://<your-domain>"
    fi

    if [ $GLPI_AUTO_UPDATE ]; then
        echo_line "Auto update is enabled. Performing database update. Please wait..."
        $BIN_CONSOLE database:update --no-interaction --quiet
    else
        echo_line "Auto update is disabled. Please use wizard at https://<your-domain>"
    fi
fi

# Welcome message
cat << '_EOF_'

Welcome to

 ██████╗ ██╗     ██████╗ ██╗
██╔════╝ ██║     ██╔══██╗██║
██║  ███╗██║     ██████╔╝██║
██║   ██║██║     ██╔═══╝ ██║
╚██████╔╝███████╗██║     ██║
 ╚═════╝ ╚══════╝╚═╝     ╚═╝
_EOF_

_DATE_TIME=`date`
echo_line "Starting GLPI at ${_DATE_TIME}..."

# Run passed command
exec "$@"
