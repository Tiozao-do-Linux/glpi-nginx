#!/bin/bash
set -e

function echo_line {
    echo "________________________________________________________________________________"
    echo "$@"
    echo "================================================================================"
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
    echo_line "PHP-FPM configuration files not found!"
    exit 1
fi

echo_line "Show PHP-FPM Version"
php-fpm -v

echo_line "PHP-FPM Configuration Test"
php-fpm -t

echo_line "PHP-FPM Loaded Modules"
FORMATTED=$(php-fpm -m | awk '/^\[/{if(NR>1)print prev; prev=$0; next}{gsub(/^\s+|\s+$/,""); if($0) prev=prev" "$0} END{print prev}')
echo "$FORMATTED"

_DATE_TIME=`date`
echo_line "PHP-FPM Starting at ${_DATE_TIME}..."

# Run php-fpm
exec "$@"