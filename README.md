# docker-nginx-php7

## Description
Docker image support Nginx and PHP 7.1 depends on Centos 7.

## Services
- Nginx
- PHP-FPM

## Usage
```
docker run -d --name nginx-php -p 8080:80  wwtg99/nginx-php:latest
```

## Volumes
- /data/www: default root directory for nginx server
- /data/conf/nginx: nginx server config directory, put your own server config here
- /data/conf/supervisord: supervisord program config directory, put your own deamon program config here
- /data/log: default log directory for nginx and supervisord

Use your own server
```
docker run -d --name nginx-php -p 8080:80 -v /your_server_dir:/data/www -v /your_server_conf_dir:/data/conf/nginx  wwtg99/nginx-php:latest
```

Notice, if /data/conf/nginx/website.conf is not exists, there will create a default server config file. So use website.conf for your config file name, or there will be conflict for port 80.

## Scripts
If you have your own scripts to run before server started(such as change timezone), add them to script.sh and rebuild the image.

## Thanks
[Skiychan](https://github.com/skiy-dockerfile/nginx-php7)

## Author

[wwtg99](http://52jing.wang)

