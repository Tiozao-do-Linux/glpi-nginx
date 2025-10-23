#!/bin/bash
set -e

_DATE_TIME=`date`
echo "[$_DATE_TIME] Executing entrypoint script"

# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm8.4 "$@"
fi

echo "-------------------------------------"
echo "First argument: $1"
echo "-------------------------------------"
php-fpm8.4 -v
echo "-------------------------------------"
php-fpm8.4 -t
echo "-------------------------------------"
php-fpm8.4 -m
echo "-------------------------------------"
echo "Starting php-fpm with the following command:"
echo "exec $@"

# Run php-fpm
exec "$@"