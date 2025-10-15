#!/bin/bash
set -e

_DATE_TIME=`date`
echo "[$_DATE_TIME] Executing entrypoint script"

# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

exec "$@"