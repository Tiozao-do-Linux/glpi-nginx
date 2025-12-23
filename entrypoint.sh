#!/bin/bash
set -e

function echo_line {
    echo ''
    echo '/------------------------------------------------------------------------------\'
    echo "| $@"
    echo '\------------------------------------------------------------------------------/'
}

cat << '_EOF'
 ____________________________________________________________________________
/\                                                                           \
\_|         PHP-FPM - https://github.com/Tiozao-do-Linux/glpi-nginx          |
  |                                                                          |
  |         with files /etc/php-fpm.conf and /etc/php-fpm.d/www.conf         |
  |   _______________________________________________________________________|_
   \_/_________________________________________________________________________/

_EOF

if ! [ -f "/etc/php-fpm.conf" -a -f "/etc/php-fpm.d/www.conf" ]; then
    echo_line "PHP-FPM configuration files (/etc/php-fpm.conf or /etc/php-fpm.d/www.conf) not found!"
    exit 1
fi

echo_line "Show PHP Version"
php -v

echo_line "PHP-FPM Configuration Test"
php-fpm -t

echo_line "PHP Loaded Modules"
FORMATTED=$(php -m | awk '/^\[/{if(NR>1)print prev; prev=$0; next}{gsub(/^\s+|\s+$/,""); if($0) prev=prev" "$0} END{print prev}')
echo "$FORMATTED"

GLPI_VERSION_SRC=`ls /usr/src/glpi/version/`
GLPI_VERSION_INSTALLED=`ls /var/www/html/glpi/version/`

# Verify if VERSION_SRC is different of VERSION_INSTALLED
if [ "$GLPI_VERSION_SRC" != "$GLPI_VERSION_INSTALLED" ]; then
    echo_line "The GLPI version has been changed"
    rsync -a /usr/src/glpi/ /var/www/html/glpi/
fi

echo_line "Wait 10 seconds for the database to be ready..."
sleep 10

if ! php glpi/bin/console -q system:check_requirements
then
    echo_line "Requirements not met! Exiting...";
    exit 1
fi

if php glpi/bin/console -q database:check_schema_integrity
then
    echo_line "GLPI is already configured. Update database schema if needed"
    php glpi/bin/console -q database:update --no-interaction
else
    if [ "$GLPI_AUTO_INSTALL" = "true" ]; then
        echo_line "GLPI is not configured yet. Performing CLI installation"
        php glpi/bin/console -q db:install \
        --default-language="$GLPI_LANG" \
        --db-host="$GLPI_DB_HOST" \
        --db-port="$GLPI_DB_PORT" \
        --db-name="$GLPI_DB_NAME" \
        --db-user="$GLPI_DB_USER" \
        --db-password="$GLPI_DB_PASSWORD" \
        --no-interaction \
        --reconfigure
    
        # Without this, sometimes GLPI shows:
        # Oops! An Error Occurred - The server returned a "500 Internal Server Error"
        # glpi/vendor/symfony/error-handler/Resources/views/error.html.php
        echo_line "Clearing GLPI cache to avoid '500 Internal Server Error'"
        # php glpi/bin/console -q cache:clear
        rm -rf glpi/files/_cache/${GLPI_VERSION_INSTALLED}*
    
    else
        echo_line "GLPI is not configured yet. Please use wizard at https://<your-domain>"
    fi
fi

echo_line "Enable GLPI Cron for Automatic Actions"
cat > /etc/cron.d/glpi << _EOF_
# GLPI Cron
* * * * * root php /var/www/html/glpi/front/cron.php > /dev/null 2>&1
_EOF_

# Start cron daemon in background
crond -s    # -s: log cron jobs to syslog

_DATE_TIME=`date`
echo_line "PHP-FPM Starting ($@) at ${_DATE_TIME}..."

# Run php-fpm
exec "$@"
