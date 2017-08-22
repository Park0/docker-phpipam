# Dockerfile phpipam 1.3

Hosted at https://github.com/Park0/docker-phpipam/

Based on a docker image from Clint Armstrong https://github.com/clinta/phpipam

  - Phpipam version 1.3
  - LDAP support added
  - All config values using ENV variables

## Settings

Most config settings are changeable using ENV variables

```
MYSQL_HOST="db" 
MYSQL_USER="phpipam" 
MYSQL_PASSWORD="phpipamadmin" 
MYSQL_DB="phpipam" 
MYSQL_PORT="3306" 
SSL="false" 
SSL_KEY="/path/to/cert.key" 
SSL_CERT="/path/to/cert.crt" 
SSL_CA="/path/to/ca.crt" 
SSL_CAPATH="/path/to/ca_certs" 
SSL_CIPHER="DHE-RSA-AES256-SHA:AES128-SHA" \
TMPTABLE_ENGINE_TYPE="MEMORY" 
PING_CHECK_SEND_MAIL=true 
PING_CHECK_METHOD=false 
DISCOVERY_CHECK_SEND_MAIL=true 
DISCOVERY_CHECK_METHOD=false 
REMOVED_ADDRESSES_SEND_MAIL=true 
REMOVED_ADDRESSES_TIMELIMIT=604800 
RESOLVE_EMPTYONLY=true 
RESOLVE_VERBOSE=true 
DEBUGGING=false 
PHPSESSNAME="phpipam" 
GMAPS_API_KEY="" 
PROXY_ENABLED=false 
PROXY_SERVER="myproxy.something.com" 
PROXY_PORT="8080" 
PROXY_USER="USERNAME" 
PROXY_PASS="PASSWORD" 
PROXY_USE_AUTH=false
LOGO_WIDTH=220
```

## Run command

In this case there is a mariadb docker image running with a database/user phpipam and password: randompassword
```
docker run -d --name=phpipam \ 
    --link mariadb:db \
    -e MYSQL_PASSWORD="randompassword" \ 
    park0/docker-phpipam
```

## Letsencrypt reverse proxy

```
docker run -d --name nginx-proxy -p 80:80 -p 443:443 \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v /opt/docker/nginx-proxy/certs:/etc/nginx/certs \
    -v /opt/docker/nginx-proxy/vhost.d:/etc/nginx/vhost.d:ro \
    -v /opt/docker/nginx-proxy/html:/usr/share/nginx/html:ro \
    -v /opt/docker/nginx-proxy/conf.d:/etc/nginx/conf.d/:rw \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy=true \
    jwilder/nginx-proxy
```

/opt/docker/nginx-proxy/vhost.d/phpipam.example.org

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-FORWARDED-HOST phpipam.example.org;
```

Make sure u create a database phpipam with a user phpipam and password randompassword. 

```
docker run -d --name=phpipam \ 
    --link mariadb:db \
    -e MYSQL_PASSWORD="randompassword" \
    -e VIRTUAL_HOST=phpipam.example.org \
    -e LETSENCRYPT_HOST=phpipam.example.org \
    -e LETSENCRYPT_EMAIL=letsencrypt@example.org \
    park0/docker-phpipam
```

## Found a bug

Please file a issue on github (or a pull request if u can). 

## Build & push command

```
docker build -t park0/dodocker-phpipam:1.3 -t park0/dodocker-phpipam -t park0/dodocker-phpipam:1.3.x .
```
