# GLPI - (POC - Proof of concept)

![Logo-GLPI-bombado](screenshots/Logo-GLPI-bombado.png)

> Before moving on, please consider giving us a GitHub star ⭐️. Thank you!
> 
Although there is already an **Official Version of GLPI** (https://github.com/glpi-project/glpi) on **Docker Hub** (https://hub.docker.com/r/glpi/glpi), I believe it is possible to use other more performant *Docker Images* in a `docker-compose.yml` and just map the source code inside these containers.

## What do I gain from this?
- The [docker-compose.yml](docker-compose.yml) file is very simple. Take a look.
- If NGINX or MariaDB receives an update, it will not be necessary to rebuild the glpi-fpm image.
- If PHP or GLPI itself receives an update, it will be necessary to create a new glpi-fpm image to reflect the updates. This procedure is performed daily by the [workflow](.github/workflows/build-and-push-multi-platform.yml).
- The [jarbelix/glpi-fpm](https://hub.docker.com/r/jarbelix/glpi-fpm/tags?name=latest) image size is SMALLER than [glpi/glpi](https://hub.docker.com/r/glpi/glpi/tags?name=latest) and the **jarbelix/glpi-fpm** image supports both *amd64* and *arm64* architectures, while the **glpi/glpi** image only supports *amd64*.
- Why PHP-FPM with Nginx ?
  - Understanding PHP-FPM - https://dev.to/arsalanmee/understanding-php-fpm-a-comprehensive-guide-3ng8
  - Demystifying Nginx and PHP-FPM - https://medium.com/@mgonzalezbaile/demystifying-nginx-and-php-fpm-for-php-developers-bba548dd38f9
  - How to Configure PHP-FPM with NGINX - https://www.digitalocean.com/community/tutorials/php-fpm-nginx
- And yes, I chose Nginx because it's more performant than Apache.

### How to keep everything up to date
- Just do a `docker compose pull` within the directory where docker-compose.yml is located to download the new versions and then a `docker compose up -d` and the new versions will already be in use.

# Simple and straightforward
```bash
git clone https://github.com/Tiozao-do-Linux/glpi-nginx.git

cd glpi-nginx

cp env.example .env

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
jarbelix/glpi-fpm   latest    60131ae3c08d   5 seconds ago   717MB
nginx               latest    07ccdb783875   11 days ago     152MB
mariadb             latest    dfbea441e6fc   2 months ago    330MB
```

## List glpi related volumes
```bash
docker volume ls | grep _glpi
```

## Accessing the container shell
```bash
docker exec -it glpi-nginx-glpi-fpm-1 bash
```

## View only glpi-fpm logs online
```
docker compose logs glpi-fpm -f --tail 50
```

```
glpi-fpm-1  |  ____________________________________________________________________________
glpi-fpm-1  | /\                                                                           \
glpi-fpm-1  | \_|         PHP-FPM - https://github.com/Tiozao-do-Linux/glpi-nginx          |
glpi-fpm-1  |   |                                                                          |
glpi-fpm-1  |   |         with files /etc/php-fpm.conf and /etc/php-fpm.d/www.conf         |
glpi-fpm-1  |   |   _______________________________________________________________________|_
glpi-fpm-1  |    \_/_________________________________________________________________________/
glpi-fpm-1  | 
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | Show PHP Version
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | PHP 8.5.0 (cli) (built: Nov 18 2025 08:02:20) (NTS gcc x86_64)
glpi-fpm-1  | Copyright (c) The PHP Group
glpi-fpm-1  | Built by Remi's RPM repository <https://rpms.remirepo.net/> #StandWithUkraine
glpi-fpm-1  | Zend Engine v4.5.0, Copyright (c) Zend Technologies
glpi-fpm-1  |     with Zend OPcache v8.5.0, Copyright (c), by Zend Technologies
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | PHP-FPM Configuration Test
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | [07-Dec-2025 16:24:57] NOTICE: configuration file /etc/php-fpm.conf test is successful
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | PHP Loaded Modules
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | [PHP Modules] apcu bcmath bz2 calendar Core ctype curl date dom exif fileinfo filter ftp gd gettext hash iconv intl json ldap libxml mbstring mysqli mysqlnd openssl pcntl pcre PDO pdo_mysql pdo_sqlite Phar random readline Reflection session SimpleXML snmp soap sockets sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter xsl Zend OPcache zip zlib
glpi-fpm-1  | [Zend Modules] Zend OPcache
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | Wait 10 seconds for the database to be ready...
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | Unable to connect to database.
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | GLPI is not configured yet. Performing CLI installation
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | 
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | Clearing GLPI cache...
glpi-fpm-1  | \------------------------------------------------------------------------------/
glpi-fpm-1  | 
glpi-fpm-1  | /------------------------------------------------------------------------------\
glpi-fpm-1  | | PHP-FPM Starting (php-fpm -F) at Sun Dec  7 16:25:29 UTC 2025...
glpi-fpm-1  | \------------------------------------------------------------------------------/

```

## My glpi-fpm images in hub.docker.com

* https://hub.docker.com/r/jarbelix/glpi-fpm/tags

# Wizard Installation

* Open a browser with the URL https://localhost

## GLPI Setup

![Tela-01](screenshots/glpi-page-01.png)

## Select your language

![Tela-02](screenshots/glpi-page-02.png)

## License

![Tela-03](screenshots/glpi-page-03.png)

## Install or Upgrade GLPI

![Tela-04](screenshots/glpi-page-04.png)

## Checking your environment #1

![Tela-05](screenshots/glpi-page-05.png)

## Checking your environment #2

![Tela-06](screenshots/glpi-page-06.png)

## Database connection setup

![Tela-07](screenshots/glpi-page-07.png)

## Test database connection

![Tela-08](screenshots/glpi-page-08.png)

## Initialize database #1

![Tela-09](screenshots/glpi-page-09.png)

## Initialize database #2

![Tela-10](screenshots/glpi-page-10.png)

## Collect data

![Tela-11](screenshots/glpi-page-11.png)

## One last thing before starting GLPI

![Tela-12](screenshots/glpi-page-12.png)

## The instalation is finished

![Tela-13](screenshots/glpi-page-13.png)

## Login to your account

![Tela-14](screenshots/glpi-page-14.png)

## Your Dashboard

![Tela-15](screenshots/glpi-page-15.png)

## Checking Version of GLPI

![Tela-16](screenshots/glpi-page-16.png)

## My POC environment

* https://glpi.tiozaodolinux.com/
* https://glpi.tiozaodolinux.com/info.php
* https://glpi.tiozaodolinux.com/status/nginx
* https://glpi.tiozaodolinux.com/status/fpm

-----

# Generating Self-Signed Certificates

A single command line with openssl is all it takes to obtain the private key (`nginx.key`) and certificate (`nginx.crt`) files. The files in this repository were generated as follows:
```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout nginx.key -out nginx.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```
* Source: https://ecostack.dev/posts/nginx-self-signed-https-docker-compose/

# Customizing with Your Preferences

The [Dockerfile](Dockerfile) file is very simple. Take a look and clear up any doubts. I used [AlmaLinux](https://almalinux.org/) as a base to install the packages related to PHP. 

The [docker-compose.yml](docker-compose.yml) file can be edited to reflect your preferences (exposed ports, image versions, etc.).

The [custom-nginx.conf](custom-nginx.conf) file contains the basic Nginx server configurations.

The [custom-php.ini](custom-php.ini) file contains the PHP variable configurations.

## Important

In **production** mode, adjust the locations in `custom-nginx.conf` to allow only your networks. Comment out the 'allow all' line and uncomment the line corresponding to your network.

# Backup

See [complete-backup script](complete-backup.md)
