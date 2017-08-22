FROM php:5.6-apache
MAINTAINER Park0 <Park0@github>

# Install required deb packages
RUN apt-get update && \ 
	apt-get install -y git php-pear php5-curl php5-mysql php5-json php5-gmp php5-mcrypt php5-ldap libgmp-dev \ 
	libmcrypt-dev libfreetype6-dev libjpeg62-turbo-dev libpng12-dev && \
	rm -rf /var/lib/apt/lists/*

# Configure apache and required PHP modules 
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	docker-php-ext-install mysqli && \
	docker-php-ext-install pdo_mysql && \
        docker-php-ext-install gettext && \ 
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
	docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu && \
	docker-php-ext-install gmp && \
        docker-php-ext-install mcrypt && \
	docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install -j$(nproc) gd && \
	docker-php-ext-install sockets && \
	docker-php-ext-install pcntl && \
	echo ". /etc/environment" >> /etc/apache2/envvars && \
	a2enmod rewrite && \
	cp /usr/lib/php5/20131226/ldap.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ && \
	cp /etc/php5/mods-available/ldap.ini /usr/local/etc/php/conf.d/


ENV PHPIPAM_SOURCE="https://github.com/phpipam/phpipam/archive/" \
    PHPIPAM_VERSION="1.3" \
    MYSQL_HOST="db" \
    MYSQL_USER="phpipam" \
    MYSQL_PASSWORD="phpipamadmin" \
    MYSQL_DB="phpipam" \
    MYSQL_PORT="3306" \
    SSL="false" \
    SSL_KEY="/path/to/cert.key" \
    SSL_CERT="/path/to/cert.crt" \
    SSL_CA="/path/to/ca.crt" \
    SSL_CAPATH="/path/to/ca_certs" \
    SSL_CIPHER="DHE-RSA-AES256-SHA:AES128-SHA" \ 
    TMPTABLE_ENGINE_TYPE="MEMORY" \
    PING_CHECK_SEND_MAIL=true \
    PING_CHECK_METHOD=false \
    DISCOVERY_CHECK_SEND_MAIL=true \
    DISCOVERY_CHECK_METHOD=false \
    REMOVED_ADDRESSES_SEND_MAIL=true \
    REMOVED_ADDRESSES_TIMELIMIT=604800 \
    RESOLVE_EMPTYONLY=true \
    RESOLVE_VERBOSE=true \
    DEBUGGING=false \
    PHPSESSNAME="phpipam" \
    GMAPS_API_KEY="" \
    PROXY_ENABLED=false \
    PROXY_SERVER="myproxy.something.com" \
    PROXY_PORT="8080" \
    PROXY_USER="USERNAME" \
    PROXY_PASS="PASSWORD" \
    PROXY_USE_AUTH=false \
    LOGO_WIDTH=220

COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
ADD ${PHPIPAM_SOURCE}/${PHPIPAM_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/${PHPIPAM_VERSION}.tar.gz -C /var/www/html/ --strip-components=1 && \
    cp /var/www/html/config.dist.php /var/www/html/config.php

# Use system environment variables into config.php
RUN sed -i \ 
	-e "s/\['host'\] = 'localhost'/\['host'\] = getenv(\"MYSQL_HOST\")/" \
    -e "s/\['user'\] = 'phpipam'/\['user'\] = getenv(\"MYSQL_USER\")/" \
    -e "s/\['pass'\] = 'phpipamadmin'/\['pass'\] = getenv(\"MYSQL_PASSWORD\")/" \
    -e "s/\['name'\] = 'phpipam'/\['name'\] = getenv(\"MYSQL_DB\")/" \
    -e "s/\['port'\] = 3306/\['port'\] = getenv(\"MYSQL_PORT\")/" \
    -e "s/\['ssl'\] *= false/\['ssl'\] = getenv(\"SSL\")/" \
    -e "s/\['ssl_key'\] *= '\/path\/to\/cert.key'/['ssl_key'\] = getenv(\"SSL_KEY\")/" \
    -e "s/\['ssl_cert'\] *= '\/path\/to\/cert.crt'/['ssl_cert'\] = getenv(\"SSL_CERT\")/" \
    -e "s/\['ssl_ca'\] *= '\/path\/to\/ca.crt'/['ssl_ca'\] = getenv(\"SSL_CA\")/" \
    -e "s/\['ssl_capath'\] *= '\/path\/to\/ca_certs'/['ssl_capath'\] = getenv(\"SSL_CAPATH\")/" \
    -e "s/\['ssl_cipher'\] *= '\/DHE-RSA-AES256-SHA:AES128-SHA'/['ssl_cipher'\] = getenv(\"SSL_CIPHER\")/" \
    -e "s/\['tmptable_engine_type'\] = \"MEMORY\"/['tmptable_engine_type'\] = getenv(\"TMPTABLE_ENGINE_TYPE\")/" \
    -e "s/\['ping_check_send_mail'\] *= true/['ping_check_send_mail'\] = strtolower(getenv(\"PING_CHECK_SEND_MAIL\")) == 'true' \? true:false/" \
    -e "s/\['ping_check_method'\] *= false/['ping_check_method'\] = strtolower(getenv(\"PING_CHECK_METHOD\")) == 'false' \? false:getenv(\"PING_CHECK_METHOD\")/" \
    -e "s/\['discovery_check_send_mail'\] *= true/['discovery_check_send_mail'\] = strtolower(getenv(\"DISCOVERY_CHECK_SEND_MAIL\")) == 'true' \? true:false/" \
    -e "s/\['discovery_check_method'\] *= false/['discovery_check_method'\] = strtolower(getenv(\"DISCOVERY_CHECK_METHOD\")) == 'false' \? false:getenv(\"DISCOVERY_CHECK_METHOD\")/" \
    -e "s/\['removed_addresses_send_mail'\] *= true/['removed_addresses_send_mail'\] = strtolower(getenv(\"REMOVED_ADDRESSES_SEND_MAIL\")) == 'true' \? true:false/" \
    -e "s/\['removed_addresses_timelimit'\] = 86400 \* 7/['removed_addresses_timelimit'\] = (int) getenv(\"REMOVED_ADDRESSES_TIMELIMIT\")/" \
    -e "s/\['resolve_emptyonly'\] *= true/['resolve_emptyonly'\] = strtolower(getenv(\"RESOLVE_EMPTYONLY\")) == 'true' \? true:false/" \
    -e "s/\['resolve_verbose'\] *= true/['resolve_verbose'\] = strtolower(getenv(\"RESOLVE_VERBOSE\")) == 'true' \? true:false/" \
    -e "s/debugging = false/debugging = strtolower(getenv(\"DEBUGGING\")) == 'true' \? true:false/" \
    -e "s/phpsessname = \"phpipam\"/phpsessname = getenv(\"PHPSESSNAME\")/" \
    -e "s/gmaps_api_key = \"\"/gmaps_api_key = getenv(\"GMAPS_API_KEY\")/" \
    -e "s/proxy_enabled *= false/proxy_enabled  = strtolower(getenv(\"PROXY_ENABLED\")) == 'true' \? true:false/" \
    -e "s/proxy_server *= 'myproxy.something.com'/proxy_server = getenv(\"PROXY_SERVER\")/" \
    -e "s/proxy_port *= '8080'/proxy_port = getenv(\"PROXY_PORT\")/" \
    -e "s/proxy_user *= 'USERNAME'/proxy_user = getenv(\"PROXY_USER\")/" \
    -e "s/proxy_pass *= 'PASSWORD'/proxy_pass = getenv(\"PROXY_PASS\")/" \
    -e "s/proxy_use_auth = false/proxy_use_auth = strtolower(getenv(\"PROXY_USE_AUTH\")) == 'true' \? true:false/" \
    -e "s/\['logo_width'\] = 220/['logo_width'\] = (int) getenv(\"LOGO_WIDTH\")/" \
    /var/www/html/config.php


EXPOSE 80
