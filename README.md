# GLPI - (POC - Proof of concept)

Although there is already an **Official Version of GLPI** (https://github.com/glpi-project/glpi) on **Docker Hub** (https://hub.docker.com/r/glpi/glpi), I believe it is possible to use other more performant *Docker Images* in a `docker-compose.yml` and just map the source code inside these containers.

## What do I gain from this?
- Not having to make another version of the GLPI image available due to a PHP, Nginx, or MariaDB update. Yes, I chose Nginx because it's more performant than Apache.

### If PHP or NGINX has any updates
- Just do a `docker compose pull` within the directory where docker-compose.yml is located to download the new versions and then a `docker compose up -d` and GLPI will already be using the new versions.

# Basic example
```bash
git clone https://github.com/Tiozao-do-Linux/glpi-nginx.git

cd glpi-nginx

cp env.example .env

docker compose build --no-cache

docker compose up -d; docker compose logs -f
```
## What's running
```bash
docker compose ps
NAME                    IMAGE               COMMAND                  SERVICE    CREATED         STATUS         PORTS
glpi-nginx-database-1   mariadb:latest      "docker-entrypoint.s…"   database   3 seconds ago   Up 2 seconds   3306/tcp
glpi-nginx-glpi-fpm-1   jarbelix/glpi-fpm   "/entrypoint.sh php-…"   glpi-fpm   3 seconds ago   Up 1 second    9000/tcp
glpi-nginx-nginx-1      nginx:latest        "/docker-entrypoint.…"   nginx      3 seconds ago   Up 1 second    0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp
```
## Size of images used
```bash
docker images | grep -E '(REPOSITORY|glpi-fpm|mariadb|nginx)'
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
jarbelix/glpi-fpm   latest    0d5936e99185   5 seconds ago   876MB
nginx               latest    07ccdb783875   11 days ago     160MB
mariadb             latest    dfbea441e6fc   2 months ago    330MB
```

## Web Interface

* Here is working: https://localhost/info.php

## Wizard Instalation
 
* https://localhost - It's giving an error

```
GLPI setup

The GLPI database must be configured and installed.

[Go to install page](https://localhost/install/install.php)

```
* https://localhost/install/install.php - say:
```
File not found.
```

## My POC environment

* https://glpi.tiozaodolinux.com/
* https://glpi.tiozaodolinux.com/info.php
* https://glpi.tiozaodolinux.com/install/install.php
* **Where am I going wrong?**

-----

# Generating Self-Signed Certificates

A single command line with openssl is all it takes to obtain the private key (`nginx.key`) and certificate (`nginx.crt`) files. The files in this repository were generated as follows:
```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout nginx.key -out nginx.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```
* Source: https://ecostack.dev/posts/nginx-self-signed-https-docker-compose/

# Customizing with Your Preferences

The [docker-compose.yml](docker-compose.yml) file can be edited to reflect your preferences (exposed ports, image versions, etc.). When in production, remove the `info.php` entry, which serves only to validate that the PHP variables were applied correctly. I chose to uncomment this line in my demo environment, so see https://glpi.tiozaodolinux.com/info.php

The [custom-nginx.conf](custom-nginx.conf) file contains the basic Nginx server configurations.

The [custom-php.ini](custom-php.ini) file contains the PHP variable configurations.
