FROM php:8.3-fpm 

# Labels
LABEL description="GLPI Docker Container with php-fpm and nginx"
LABEL version="GLPI Latest Stable"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"

# Disable interactive mode for debian packages only in build phase
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN <<EOF
# Update packages
apt-get update
apt-get upgrade -y

# Install PHP nodules
# To enable PHP modules in a php:fpm Docker image, you typically use a custom Dockerfile to extend the base image.
# This involves installing necessary system dependencies and then using the docker-php-ext-install or docker-php-ext-enable commands provided by the official PHP Docker images.
apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libldap2-dev libzip-dev libicu-dev libmariadb-dev

# Install PHP extensions
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) gd intl xml opcache ldap zip mysqli pdo pdo_mysql exif

# Extra packages for convenience
# apt-get install -y htop tree iputils-ping curl jq net-tools

# Clean
apt-get remove -y --purge libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libldap2-dev libzip-dev libicu-dev libmariadb-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
# EOF

# # Install GLPI - https://glpi-install.readthedocs.io/en/latest/install/
# RUN <<EOF
# Download and extract latest stable release of GLPI
LATEST=`curl -sI https://github.com/glpi-project/glpi/releases/latest | awk -F'/' '/^location/ {sub("\r","",$NF); print $NF }'`
curl -# -L "https://github.com/glpi-project/glpi/releases/download/${LATEST}/glpi-${LATEST}.tgz" -o glpi-${LATEST}.tgz

# GLPI upstream tarballs include ./glpi/ so remove it with --strip-components=1
tar xzvf glpi-${LATEST}.tgz --no-same-owner --strip-components=1

# Clean
rm glpi-${LATEST}.tgz

# Adjust permissions (files and config directory)
chown -R www-data:www-data /var/www/html/files /var/www/html/config
EOF

# Where the GLPI files will be stored
WORKDIR /var/www/html

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# What user should run the app
#USER www-data

# Defines volumes to be supported
VOLUME /var/www/html

# Expose the port of php-fpm
EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm"]
