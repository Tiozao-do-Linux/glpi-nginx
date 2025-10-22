FROM php:fpm

# Add metadata to an image.
LABEL maintainer="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL org.opencontainers.image.authors="Tiozão do Linux <jarbas.junior@gmail.com>"
LABEL description="GLPI Docker Container with php-fpm"
LABEL version="GLPI Latest Stable"

# Avoid prompts during build
ARG DEBIAN_FRONTEND=noninteractive

# More about heredocs in Dockerfiles: https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/

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

## GLPI upstream tarballs include ./glpi/ so remove it with --strip-components=1
## tar xzvf glpi-${LATEST}.tgz --no-same-owner --strip-components=1

# Extract GLPI
tar xzvf glpi-${LATEST}.tgz --no-same-owner

# Clean
rm glpi-${LATEST}.tgz
EOF

# Adjust permissions - https://glpi-install.readthedocs.io/en/latest/install/
RUN <<EOF
chown -R www-data:www-data glpi/files glpi/config

# Create custom directories for config and files outside web root
mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi
chown -R www-data:www-data /etc/glpi /var/lib/glpi /var/log/glpi
EOF

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# Defines volumes to be supported
VOLUME /var/www/html

# Expose the port of php-fpm
EXPOSE 9000

# What user should run the app
# USER www-data

# Check a container's health on startup.
# HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD pgrep php-fpm >/dev/null 2>&1 || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["php-fpm"]
