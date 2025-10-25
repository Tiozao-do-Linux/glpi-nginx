#!/bin/bash
set -e

_DATE_TIME=`date`
echo "[$_DATE_TIME] Executing entrypoint script"

# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm"$@"
fi

echo "-------------------------------------"
echo "First argument: $1"
echo "-------------------------------------"
php-fpm -v
echo "-------------------------------------"
php-fpm -t
echo "-------------------------------------"
php-fpm -m
echo "-------------------------------------"
echo "Starting php-fpm with the following command:"
echo "exec $@"

# Run php-fpm
exec "$@"