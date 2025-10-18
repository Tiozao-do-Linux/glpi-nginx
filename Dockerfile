FROM php:fpm

# Add metadata to an image.
LABEL maintainer="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL description="GLPI Docker Container with php-fpm"
LABEL version="GLPI Latest Stable"

# Avoid prompts during build
ARG DEBIAN_FRONTEND=noninteractive

# More about heredocs in Dockerfiles: https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/

# # Install necessary packages
# RUN <<EOF
# # Update packages
# apt-get update
# apt-get upgrade -y

# # Install PHP nodules
# # To enable PHP modules in a php:fpm Docker image, you typically use a custom Dockerfile to extend the base image.
# # This involves installing necessary system dependencies and then using the docker-php-ext-install or docker-php-ext-enable commands provided by the official PHP Docker images.
# apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libldap2-dev libzip-dev libicu-dev libmariadb-dev

# # Install PHP extensions
# docker-php-ext-configure gd --with-freetype --with-jpeg
# docker-php-ext-install -j$(nproc) gd intl xml opcache ldap zip mysqli pdo pdo_mysql exif

# # Extra packages for convenience
# # apt-get install -y htop tree iputils-ping curl jq net-tools

# # Clean
# apt-get remove -y --purge libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libldap2-dev libzip-dev libicu-dev libmariadb-dev
# apt-get clean
# rm -rf /var/lib/apt/lists/*
# EOF

# Install extra packages for convenience
RUN <<EOF
# Update packages
apt-get update
apt-get upgrade -y
apt-get install -y htop tree iputils-ping curl jq net-tools
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

# Where the GLPI files will be stored inside the container
WORKDIR /var/www/html

# Install GLPI
RUN <<EOF
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

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# What user should run the app
#USER www-data

# Defines volumes to be supported
VOLUME /var/www/html

# Expose the port of php-fpm
EXPOSE 9000

# Check a container's health on startup.
# HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD pgrep php-fpm >/dev/null 2>&1 || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm"]
