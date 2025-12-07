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
# echo_line "GLPI Version Source: $GLPI_VERSION_SRC"

GLPI_VERSION_INSTALLED=`ls /var/www/html/glpi/version/`
# echo_line "GLPI Version Installed: $GLPI_VERSION_INSTALLED"

# Verify if VERSION_SRC is different of VERSION_INSTALLED
if [ "$GLPI_VERSION_SRC" != "$GLPI_VERSION_INSTALLED" ]; then
    echo_line "GLPI Version changed detected"
    rsync -a /usr/src/glpi/ /var/www/html/glpi/
    # echo_line "File sync completed."
fi

# glpi/vendor/symfony/error-handler/Resources/views/error.html.php


echo_line "Wait 10 seconds for the database to be ready..."
sleep 10

# echo_line "See GLPI Console Commands Available:"
# php glpi/bin/console

# echo_line "Check system requirements to run GLPI"
if ! php glpi/bin/console -q system:check_requirements
then
    echo_line "Requirements not met! Exiting...";
    exit 1
fi

# echo_line "Check if GLPI is already confgured"
if php glpi/bin/console -q database:check_schema_integrity
then
    echo_line "GLPI is already configured."
    echo_line "Enable maintenance mode"
    php glpi/bin/console -q maintenance:enable
    echo_line "Update database schema if needed"
    php glpi/bin/console -q database:update --no-interaction
    echo_line "Disable maintenance mode"
    php glpi/bin/console -q maintenance:disable
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
    
        # Without this, sometimes GLPI shows error 500
        # Oops! An Error Occurred - The server returned a "500 Internal Server Error"
        echo_line "Clearing GLPI cache..."
        # php glpi/bin/console -q cache:clear
        rm -rf glpi/files/_cache/${GLPI_VERSION_INSTALLED}*
    
    else
        echo_line "GLPI is not configured yet. Please use wizard at https://<your-domain>"
    fi
fi

_DATE_TIME=`date`
echo_line "PHP-FPM Starting ($@) at ${_DATE_TIME}..."

# Run php-fpm
exec "$@"
