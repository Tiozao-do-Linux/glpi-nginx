FROM almalinux:9

# Set environment variables
ENV GLPI_HOME_DIR=/var/www/glpi
ENV GLPI_DATA_DIR=/var/glpi

ENV HOME_DIR=/var/www

ENV GLPI_INSTALL_MODE=DOCKER
ENV GLPI_CONFIG_DIR=${GLPI_DATA_DIR}/config
ENV GLPI_VAR_DIR=${GLPI_DATA_DIR}/files
ENV GLPI_MARKETPLACE_DIR=${GLPI_DATA_DIR}/marketplace
ENV GLPI_LOG_DIR=${GLPI_DATA_DIR}/logs

ENV GLPI_USER=nginx
ENV GLPI_GROUP=nginx

# Add metadata to an image.
LABEL description="GLPI Docker Container with php-fpm"
LABEL version="GLPI Latest Stable"
LABEL maintainer="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"

# Use heredoc to run multiple commands in a single RUN instruction.
# https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/

# Install necessary packages
RUN <<_EOF_

# Install necessary packages

# Configure PHP repository Remi - https://rpms.remirepo.net/
dnf -qy install 'dnf-command(config-manager)'
dnf -qy config-manager --set-enabled crb
dnf -qy install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf -qy install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf -qy module switch-to php:remi-8.5

# Cron for GLPI automatic actions
#dnf -qy install cronie procps-ng supervisor
dnf -qy install supervisor

# Necessary packages
dnf -qy install php-{fpm,cli,ldap,soap,curl,snmp,zip,apcu,gd,mbstring,xml,bz2,intl,bcmath,mysqlnd}

# Additional PHP extensions
dnf -qy install php-{opcache,sodium}

# The TLS_REQCERT never setting in the context of PHP and LDAP refers to disabling the server
# certificate validation when establishing a TLS (Transport Layer Security) connection to an LDAP server.
echo -e "TLS_REQCERT\tnever" >> /etc/openldap/ldap.conf

# Extra packages
dnf -qy install epel-release
dnf -qy install net-tools nmap htop

# # Update packages
# dnf -qy upgrade

# Clean up
dnf clean all

# Define a new home directory for the GLPI user
usermod -d ${HOME_DIR} ${GLPI_USER}

_EOF_

# Where the GLPI files will be stored inside the container
WORKDIR ${GLPI_HOME_DIR}

# Install GLPI
RUN <<_EOF_

# Up one level to download and extract GLPI
cd ..

# Download and extract latest stable release of GLPI
LATEST=`curl -sI https://github.com/glpi-project/glpi/releases/latest | awk -F'/' '/^location/ {sub("\r","",$NF); print $NF }'`
curl -s -L "https://github.com/glpi-project/glpi/releases/download/${LATEST}/glpi-${LATEST}.tgz" -o glpi-${LATEST}.tgz

# Extract GLPI files
tar xzf glpi-${LATEST}.tgz --no-same-owner -C ./ 2>/dev/null

# Remove downloaded file
rm glpi-${LATEST}.tgz

# Set proper permissions
chown -R ${GLPI_USER}:${GLPI_GROUP} ${GLPI_HOME_DIR}

# Create a directory for persistent files
mkdir -p ${GLPI_DATA_DIR}
chown -R ${GLPI_USER}:${GLPI_GROUP} ${GLPI_DATA_DIR}

# # Set group sticky bit on data directory to maintain group ownership
# chmod -R g+s ${GLPI_DATA_DIR}

_EOF_

# Configure PHP-FPM and Supervisor and Cron Job
RUN <<_EOF_

# Configure PHP-FPM and Supervisor and Cron Job

# Create loop script to simulate a cron job
cat > /usr/bin/cronjob.sh << _INSIDE_EOF_
#!/bin/bash
set -e -u -o pipefail
while true; do
    echo "[GLPI Cron Job][\$(date)][${GLPI_USER}] : [php ${GLPI_HOME_DIR}/front/cron.php]"
    php ${GLPI_HOME_DIR}/front/cron.php
    sleep 60
done
_INSIDE_EOF_
chmod +x /usr/bin/cronjob.sh


# Adjust permissions for run PHP-FPM with ${GLPI_USER}
##ln -s /tmp/php-fpm.pid /var/run/php-fpm.pid
sed -i 's|^pid =.*|pid = /tmp/php-fpm.pid|' /etc/php-fpm.conf
##mkdir -p /var/log/php-fpm
chown -R ${GLPI_USER}:${GLPI_GROUP} /var/log/php-fpm

# Create www.conf file from scratch to avoid conflicts
cat > /etc/php-fpm.d/www.conf << _INSIDE_EOF_
[www]
;user = nginx
;group = nginx
listen = 9000
listen.acl_users = nginx
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.status_path = /status/fpm
slowlog = /var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
_INSIDE_EOF_


# Configure Supervisor to manage php-fpm and cron
cat > /etc/supervisord.conf << _INSIDE_EOF_
[supervisord]
nodaemon=true           ; (start in foreground if true;default false)
loglevel=critical       ; (log level;default info; others: debug,warn,trace)
user=${GLPI_USER}       ; (default is current user, required if root)
logfile=/dev/null       ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=0      ; (max main logfile bytes b4 rotation;default 50MB)

[program:php-fpm]
command=/usr/sbin/php-fpm -F
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/null
stderr_logfile_maxbytes=0

[program:glpi-cron]
command=/usr/bin/cronjob.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/null
stderr_logfile_maxbytes=0
_INSIDE_EOF_

_EOF_

RUN <<_EOF_

# Create local_define.php to set custom directories

# https://github.com/glpi-project/docker-images/issues/230
# PHP Warning:  Constant GLPI_CONFIG_DIR already defined, this will be an error in PHP 9

cat > /var/www/glpi/config/local_define.php << _INSIDE_EOF_
<?php
define('GLPI_CONFIG_DIR', '${GLPI_CONFIG_DIR}');
define('GLPI_VAR_DIR', '${GLPI_VAR_DIR}');
define('GLPI_LOG_DIR', '${GLPI_LOG_DIR}');
define('GLPI_MARKETPLACE_DIR', '${GLPI_MARKETPLACE_DIR}');
_INSIDE_EOF_

_EOF_


# Copy entrypoint into the container
COPY entrypoint.sh /entrypoint.sh

# Where the GLPI files will be stored inside the container
WORKDIR ${GLPI_HOME_DIR}

# Defines volumes to be supported
VOLUME [ ${GLPI_HOME_DIR} ${GLPI_DATA_DIR} ]

# Expose the port of php-fpm
EXPOSE 9000

USER ${GLPI_USER}

ENTRYPOINT [ "/entrypoint.sh" ]
# CMD ["php-fpm", "-F"]
# CMD ["/usr/sbin/crond", "-n"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]