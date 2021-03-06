#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the Larazest web server stack
# ------------------------------------------------------------------------------

apt-get update

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

# install nginx
apt-get -y install nginx

# copy a development-only default site configuration
cp /provision/conf/nginx-development /etc/nginx/sites-available/default

# disable 'daemonize' in nginx (because we use runit instead)
#echo "daemon off;" >> /etc/nginx/nginx.conf

# use runit to supervise nginx
mkdir /etc/service/nginx
cp /provision/service/nginx.sh /etc/service/nginx/run

# ------------------------------------------------------------------------------
# PHP5
# ------------------------------------------------------------------------------

# install PHP, PHP mcrypt extension and PHP MySQL native driver
apt-get -y install php5-fpm php5-cli php5-mcrypt php5-mysqlnd

# copy FPM and CLI PHP configurations
cp /provision/conf/php.fpm.ini /etc/php5/fpm/php.ini
cp /provision/conf/php.cli.ini /etc/php5/cli/php.ini

# enable PHP mcrypt extension
php5enmod mcrypt

# disable 'daemonize' in php5-fpm (because we use runit instead)
#sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

# use runit to supervise php5-fpm
mkdir /etc/service/phpfpm
cp /provision/service/phpfpm.sh /etc/service/phpfpm/run

# ------------------------------------------------------------------------------
# MySQL server
# ------------------------------------------------------------------------------

# install MySQL client and server
apt-get -y install mysql-client
apt-get -y install mysql-server pwgen

# copy MySQL configuration
cp /provision/conf/my.cnf /etc/mysql/my.cnf

# use runit to supervise mysql
mkdir /etc/service/mysql
cp /provision/service/mysql.sh /etc/service/mysql/run

# ------------------------------------------------------------------------------
# Git version control
# ------------------------------------------------------------------------------

# install git
apt-get -y install git

# ------------------------------------------------------------------------------
# Composer PHP dependency manager
# ------------------------------------------------------------------------------

# install the latest version of composer
php -r "readfile('https://getcomposer.org/installer');" | php
mv composer.phar /usr/local/bin/composer

#creando la carpeta para el laravel
mkdir /var/www
mkdir /var/www/laravel

# bajando el laravel
composer create-project laravel/laravel /var/www/laravel/ 4.1
#asignando permisos a la carpeta storage
chmod 777 -R /var/www/laravel/app/storage

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision

# iniciando nginx,fpm,mysql
service nginx start
service php5-fpm start
service mysql start
