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

echo_line "Check system requirements to run GLPI"
if php glpi/bin/console system:check_requirements
then
    echo_line "Check if GLPI is already installed"
    if php glpi/bin/console database:check_schema_integrity
    then
        echo_line "GLPI is already installed"
    else
        echo_line "Install GLPI Automatically is disabled by default."
        echo_line "You can enable it by setting the GLPI_INSTALL environment variable to true."

        # echo_line "Is Update?"
        # php glpi/bin/console db:update

        # echo_line "Enable maintenance mode before installation"
        # php glpi/bin/console maintenance:enable
     
        # php glpi/bin/console db:install \
        # --default-language="$GLPI_LANG" \
        # --db-host="$GLPI_DB_HOST" \
        # --db-port="$GLPI_DB_PORT" \
        # --db-name="$GLPI_DB_NAME" \
        # --db-user="$GLPI_DB_USER" \
        # --db-password="$GLPI_DB_PASSWORD" \
        # --no-interaction \
        # --reconfigure

        # echo_line "Disable maintenance mode after installation"
        # php glpi/bin/console maintenance:disable
    fi
else
    echo_line "Requirements not met!";
    exit 1
fi


_DATE_TIME=`date`
echo_line "PHP-FPM Starting ($@) at ${_DATE_TIME}..."

# Run php-fpm
exec "$@"