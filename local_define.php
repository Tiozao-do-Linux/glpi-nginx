<?php
# Create local_define.php to set custom directories
# https://github.com/glpi-project/docker-images/issues/230
# PHP Warning:  Constant GLPI_CONFIG_DIR already defined, this will be an error in PHP 9
# Disable error in /etc/supervisord.conf with 'logfile=/dev/null'

define('GLPI_CONFIG_DIR', '/var/glpi/config');
define('GLPI_VAR_DIR', '/var/glpi/files');
define('GLPI_LOG_DIR', '/var/glpi/logs');
define('GLPI_MARKETPLACE_DIR', '/var/glpi/marketplace');