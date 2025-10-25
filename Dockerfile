# FROM php:fpm
FROM almalinux:10

# Add metadata to an image.
LABEL description="GLPI Docker Container with php-fpm"
LABEL version="GLPI Latest Stable"
LABEL maintainer="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"

# Use heredoc to run multiple commands in a single RUN instruction.
# https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/

# Install necessary packages
RUN <<EOF

# Update packages
dnf -y upgrade --refresh

# Necessary packages
dnf -y install php-{fpm,cli,ldap,soap,curl,snmp,zip,apcu,gd,mbstring,xml,bz2,intl,bcmath,mysqlnd}
dnf -y install php-{opcache,sodium}

# Extra packages
dnf -y install epel-release
dnf -y install net-tools nmap htop

# Adjust PHP-FPM configuration
sed -i 's|^pid =.*|pid = /var/run/php-fpm.pid|' /etc/php-fpm.conf
sed -i 's|^listen =.*|listen = 9000|' /etc/php-fpm.d/www.conf
sed -i 's|^listen.allowed_clients =.*|;listen.allowed_clients = 127.0.0.0/8|' /etc/php-fpm.d/www.conf

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

EOF

# Adjust permissions - https://glpi-install.readthedocs.io/en/latest/install/
RUN <<EOF

chown -R apache:apache glpi/files glpi/config glpi/marketplace

# # Create custom directories for config and files outside web root
# mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi
# chown -R www-data:www-data /etc/glpi /var/lib/glpi /var/log/glpi

EOF

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# Defines volumes to be supported
VOLUME /var/www/html/glpi

# Expose the port of php-fpm
EXPOSE 9000

# What user should run the app
# USER www-data

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm", "-F"]
