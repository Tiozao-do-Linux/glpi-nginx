# Imagens Bitnami

Durante 18 anos, as [Imagens Bitnami](https://github.com/bitnami/containers) eram livres para uso sem requerer subscrição/pagamento.

Desde 28/Ago/2025 a maioria das imagens requerem subscrição. Se houve algum container rodando com imagens que foram afetadas, a mensagem é mostrada:
* NOTICE: Starting August 28th, 2025, only a limited subset of images/charts will remain available for free. Backup will be available for some time at the 'Bitnami Legacy' repository. More info at https://github.com/bitnami/containers/issues/83267

Essa decisão afetou diversos usuários que antes utilizavam as Imagens de forma livre.

No caso do WordPress, a imagem que eu utilizava https://hub.docker.com/r/bitnami/wordpress-nginx não está mais disponível de forma gratuita
* As últimas estão disponíveis em https://hub.docker.com/r/bitnamilegacy/wordpress-nginx
* Você ainda pode utilizar as outras últimas do https://hub.docker.com/u/bitnamilegacy (mais sem atualização)
* Nem adianta abrir uma issue relatando o problema causado https://github.com/bitnami/containers/issues/86874
* Ainda é possível utilizar https://hub.docker.com/r/bitnami/wordpress. Mas até quando?

# GLPI - LTS (Apenas uma POC)

Embora já exista uma **Versão Oficial do GLPI** (https://github.com/glpi-project/glpi) no **Docker Hub** (https://hub.docker.com/r/glpi/glpi), eu acredito que dê pra utilizar outras *Imagens Docker* mais performáticas num `docker-compose.yml` e apenas mapear o código fonte dentro desses containers.

## O que ganho com isso?
- Não ter que disponibilizar outra versão da imagem do GLPI por conta de uma atualização do **php**, **nginx** ou **mariadb**. Sim, escolhi o nginx por ser mais performático que o apache.

### PHP tem alguma atualização
- Basta fazer um `docker compose pull` dentro do diretório onde encontra-se o docker-compose.yml para baixar a nova versão do php e depois um `docker compose up -d` que o GLPI ja estará utilizando a nova versão do PHP.

# Como obter a última versão LTS do GLPI

```bash
LATEST=`curl -sI https://github.com/glpi-project/glpi/releases/latest | awk -F'/' '/^location/ {sub("\r","",$NF); print $NF }'`

curl -# -L "https://github.com/glpi-project/glpi/releases/download/${LATEST}/glpi-${LATEST}.tgz" -o glpi-${LATEST}.tgz

tar xzvf glpi-${LATEST}.tgz -C glpi_app/
```

# Exemplo básico
```bash
docker compose up -d
```
## O que estará rodando?
```bash
docker compose ps
NAME           IMAGE             COMMAND                  SERVICE   CREATED              STATUS              PORTS
glpi-mariadb   bitnami/mariadb   "/opt/bitnami/script…"   mariadb   About a minute ago   Up About a minute   3306/tcp
glpi-nginx     bitnami/nginx     "/opt/bitnami/script…"   nginx     About a minute ago   Up About a minute   8443/tcp, 0.0.0.0:80->8080/tcp, [::]:80->8080/tcp
glpi-phpfpm    bitnami/php-fpm   "php-fpm -F --pid /o…"   phpfpm    About a minute ago   Up About a minute   9000/tcp
```
## Tamanho das imagens
```bash
docker images | grep -E "^bitnami/(mariadb|nginx|php-fpm).*latest"
bitnami/php-fpm               latest            9e3e0516c5bd   2 days ago      360MB
bitnami/nginx                 latest            6362258f3406   2 weeks ago     185MB
bitnami/mariadb               latest            d3a04feaa812   2 weeks ago     434MB
```

## Abrir o browser

- URL http://localhost:80/glpi/

