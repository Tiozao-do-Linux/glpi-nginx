FROM almalinux:9

# Add metadata to an image.
LABEL description="GLPI Docker Container with php-fpm"
LABEL version="GLPI Latest Stable"
LABEL maintainer="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"

# Use heredoc to run multiple commands in a single RUN instruction.
# https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/

# Install necessary packages
RUN <<EOF

# Configure PHP repository Remi - https://rpms.remirepo.net/
dnf -y install 'dnf-command(config-manager)'
dnf -y config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf -y module switch-to php:remi-8.4

# Extra packages
dnf -y install epel-release
dnf -y install net-tools nmap htop

# Update packages
dnf -y upgrade

# Necessary packages
dnf -y install php-{fpm,cli,ldap,soap,curl,snmp,zip,apcu,gd,mbstring,xml,bz2,intl,bcmath,mysqlnd}

# Additional PHP extensions
dnf -y install php-{opcache,sodium}

# Adjust PHP-FPM configuration
sed -i 's|^pid =.*|pid = /var/run/php-fpm.pid|' /etc/php-fpm.conf
sed -i 's|^listen =.*|listen = 9000|' /etc/php-fpm.d/www.conf
sed -i 's|^user =.*|user = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|^group =.*|group = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|^listen.allowed_clients =.*|;listen.allowed_clients =|' /etc/php-fpm.d/www.conf
sed -i 's|^;pm.status_path =.*|pm.status_path = /status/fpm|' /etc/php-fpm.d/www.conf

# The TLS_REQCERT never setting in the context of PHP and LDAP refers to disabling the server
# certificate validation when establishing a TLS (Transport Layer Security) connection to an LDAP server.
echo -e "TLS_REQCERT\tnever" >> /etc/openldap/ldap.conf

# Clean up
dnf clean all

EOF

# Where the GLPI files will be stored inside the container
WORKDIR /var/www/html

# Install GLPI
RUN <<EOF

# Download and extract latest stable release of GLPI
LATEST=`curl -sI https://github.com/glpi-project/glpi/releases/latest | awk -F'/' '/^location/ {sub("\r","",$NF); print $NF }'`
curl -# -L "https://github.com/glpi-project/glpi/releases/download/${LATEST}/glpi-${LATEST}.tgz" -o glpi-${LATEST}.tgz

# Extract GLPI
tar xzvf glpi-${LATEST}.tgz --no-same-owner

# Clean
rm glpi-${LATEST}.tgz

# Adjust permissions - https://glpi-install.readthedocs.io/en/latest/install/
chown -R nginx:nginx glpi/files glpi/config glpi/marketplace glpi/plugins

EOF

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# Defines volumes to be supported
VOLUME /var/www/html/glpi

# Expose the port of php-fpm
EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm", "-F"]
