#!/usr/bin/env bash

# Update Package List

apt-get update

apt-get upgrade -y

# Install Some PPAs

apt-get install -y software-properties-common

apt-add-repository ppa:chris-lea/node.js -y

# Update Package Lists

apt-get update

# Install Some Basic Packages

apt-get install -y build-essential curl dos2unix gcc git libmcrypt4 libpcre3-dev \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois vim

# Set My Timezone

ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# Install Apache

apt-get install -y apache2

# Install MySQL

debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
apt-get install -y mysql-server-5.6 php5-mysql

# Install SQLite

apt-get install -y sqlite3 libsqlite3-dev

# Install PHP Stuffs

apt-get install -y php5 libapache2-mod-php5 \
php5-mcrypt php5-cli php5-sqlite php5-mcrypt \
php5-xdebug php5-memcached php5-curl php5-json \
php5-gd


# Install Composer

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path

printf "\nPATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile

# Install Laravel Envoy

sudo su vagrant <<'EOF'
/usr/local/bin/composer global require "laravel/envoy=~1.0" "phpunit/phpunit:4.0.*" "codeception/codeception=*" "phpspec/phpspec:2.0.*@dev" "squizlabs/php_codesniffer:1.5.*-"
EOF

# Set Some PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = Europe/Rome/" /etc/php5/cli/php.ini

service apache2 restart

# Configure HHVM To Run As Homestead

#service apache2 stop
#sed -i 's/#RUN_AS_USER="www-data"/RUN_AS_USER="vagrant"/' /etc/default/hhvm
#service apache2 start

# Setup Some PHP Options

#sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
#sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
#sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
#sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
#sed -i "s/;date.timezone.*/date.timezone = Europe/Rome/" /etc/php5/fpm/php.ini

#echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
#echo "xdebug.remote_connect_back = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
#echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini

# Set The Apache & PHP-FPM User

#sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
#sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

#sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
#sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf

#sed -i "s/;listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
#sed -i "s/;listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
#sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

service apache2 restart

# Add Vagrant User To WWW-Data

usermod -a -G www-data vagrant
id vagrant
groups vagrant

# Install Node

apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp
npm install -g bower

# Configure MySQL Remote Access

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 10.0.2.15/' /etc/mysql/my.cnf
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'10.0.2.2' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'homestead'@'10.0.2.2' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'homestead'@'10.0.2.2' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'homestead'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE homestead;"
service mysql restart

# Install A Few Other Things

apt-get install -y memcached tmux

# Write Bash Aliases

cp /vagrant/aliases /home/vagrant/.bash_aliases
