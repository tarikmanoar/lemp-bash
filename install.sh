#!/usr/bin/env bash
#
# Follow up commands are best suitable for clean Ubuntu 20.0.0 installation
# All commands are executed by the root user
# Nginx library is installed from custom ppa/ repository
# https://launchpad.net/~hda-me/+archive/ubuntu/nginx-stable
# This will not be available for any other OS rather then Ubuntu
#
#
#Setting Up Firewall
ufw app list
ufw allow OpenSSH
ufw enable
ufw status
# Disable user promt
DEBIAN_FRONTEND=noninteractive
# Update list of available packages
apt-get update -y -q
# Install the most common packages that will be usefull under development environment
apt-get install zip unzip fail2ban htop sqlite3 nload mlocate nano memcached  software-properties-common -y -q
# Install Nginx && PHP-FPM stack
apt update
apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
add-apt-repository ppa:ondrej/php
#Installing Nginx && PHP-FPM stack
apt install software-properties-common -y -q
add-apt-repository ppa:ondrej/php -y -q
apt-get install php8.1-{cli,fpm,common,mysql,zip,gd,mbstring,curl,xml,bcmath,sqlite3,pgsql,gd,gmp,imap,intl,imagick,tokenizer} -y -q
# Delete previous Nginx installation
apt-get purge nginx-core nginx-common nginx -y -q
apt-get autoremove -y -q
# Update list of available packages
apt-get update -y -q

# Installing Composer 
echo "======================COMPOSER=========================="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Update list of available packages
apt-get update -y -q

# Install custom Nginx package
apt-get install nginx -y -q
ufw allow 'Nginx HTTP'
# systemctl status php8.1-fpm nginx
# Create an additional configuration folder for Nginx
mkdir /etc/nginx/conf.d
# Download list of bad bots, bad ip's and bad referres
# https://github.com/mitchellkrogza/nginx-badbot-blocker
wget -O /etc/nginx/conf.d/blacklist.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blacklist.conf
wget -O /etc/nginx/conf.d/blockips.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blockips.conf
# Create default file for Nginx for where to find new websites that are pointed to this IP
wget -O /etc/nginx/sites-enabled/default.conf https://raw.githubusercontent.com/tarikmanoar/lemp-bash/master/default.conf
echo "======= DEFAULT CONFIG COPY=========="
# Create fastcgi.conf
echo -e 'fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;\nfastcgi_param  QUERY_STRING       $query_string;\nfastcgi_param  REQUEST_METHOD     $request_method;\nfastcgi_param  CONTENT_TYPE       $content_type;\nfastcgi_param  CONTENT_LENGTH     $content_length;\n\nfastcgi_param  SCRIPT_NAME        $fastcgi_script_name;\nfastcgi_param  REQUEST_URI        $request_uri;\nfastcgi_param  DOCUMENT_URI       $document_uri;\nfastcgi_param  DOCUMENT_ROOT      $document_root;\nfastcgi_param  SERVER_PROTOCOL    $server_protocol;\nfastcgi_param  HTTPS              $https if_not_empty;\n\nfastcgi_param  GATEWAY_INTERFACE  CGI/1.1;\nfastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;\n\nfastcgi_param  REMOTE_ADDR        $remote_addr;\nfastcgi_param  REMOTE_PORT        $remote_port;\nfastcgi_param  SERVER_ADDR        $server_addr;\nfastcgi_param  SERVER_PORT        $server_port;\nfastcgi_param  SERVER_NAME        $server_name;\n\n# PHP only, required if PHP was built with --enable-force-cgi-redirect\nfastcgi_param  REDIRECT_STATUS    200;' > /etc/nginx/fastcgi.conf
# Create fastcgi-php.conf
echo -e '# regex to split $uri to $fastcgi_script_name and $fastcgi_path\nfastcgi_split_path_info ^(.+\.php)(/.+)$;\n\n# Check that the PHP script exists before passing it\ntry_files $fastcgi_script_name =404;\n\n# Bypass the fact that try_files resets $fastcgi_path_info\n# see: http://trac.nginx.org/nginx/ticket/321\nset $path_info $fastcgi_path_info;\nfastcgi_param PATH_INFO $path_info;\n\nfastcgi_index index.php;\ninclude fastcgi.conf;' > /etc/nginx/fastcgi-php.conf
# Create nginx.conf
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/tarikmanoar/lemp-bash/master/nginx.conf
# Tweak memcached configuration
# Disable memcached vulnerability https://thehackernews.com/2018/03/memcached-ddos-exploit-code.html
sed -i "s/^-p 11211/#-p 11211/" /etc/memcached.conf
sed -i "s/^-l 127.0.0.1/#-l 127.0.0.1/" /etc/memcached.conf
# Increase memcached performance by using sockets https://guides.wp-bullet.com/configure-memcached-to-use-unix-socket-speed-boost/
echo -e "-s /tmp/memcached.sock" >> /etc/memcached.conf
echo -e "-a 775" >> /etc/memcached.conf
# Restart memcached service
service memcached restart
# Add repository for MariaDB 10.2
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ams2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu xenial main' -y
# Update list of available packages
apt-get update -y -q
# Use md5 hash of your hostname to define a root password for MariDB
password=$(hostname | md5sum | awk '{print $1}')
debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password password $password"
debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password_again password $password"
# Install MariaDB package
apt-get install mariadb-server -y -q --fix-missing
# Add custom configuration for your Mysql
# All modified variables are available at https://mariadb.com/kb/en/library/server-system-variables/
echo -e "\n[mysqld]\nmax_connections=24\nconnect_timeout=10\nwait_timeout=10\nthread_cache_size=24\nsort_buffer_size=1M\njoin_buffer_size=1M\ntmp_table_size=8M\nmax_heap_table_size=1M\nbinlog_cache_size=8M\nbinlog_stmt_cache_size=8M\nkey_buffer_size=1M\ntable_open_cache=64\nread_buffer_size=1M\nquery_cache_limit=1M\nquery_cache_size=8M\nquery_cache_type=1\ninnodb_buffer_pool_size=8M\ninnodb_open_files=1024\ninnodb_io_capacity=1024\ninnodb_buffer_pool_instances=1" >> /etc/mysql/my.cnf
# Write down current password for MariaDB in my.cnf
echo -e "\n[client]\nuser = root\npassword = $password" >> /etc/mysql/my.cnf
# Restart MariaDB
service mysql restart
# Create default folder for future websites
mkdir /var/www
# Create Hello World page
mkdir /var/www/test.com
echo -e "<html>\n<body>\n<h1>Hello World!<h1>\n</body>\n</html>" > /var/www/test.com/index.html
# Create opcache page
wget -O /var/www/test.com/opcache.php https://github.com/rlerdorf/opcache-status/blob/master/opcache.php
# Create phpinfo page
echo -e "<?php phpinfo();" > /var/www/test.com/info.php
# Give Nginx permissions to be able to access these websites
chown -R www-data:www-data /var/www/*
# Maximize the limits of file system usage
echo -e "*       soft    nofile  1000000" >> /etc/security/limits.conf
echo -e "*       hard    nofile  1000000" >> /etc/security/limits.conf
# Switch to the ondemand state of PHP-FPM
sed -i "s/^pm = .*/pm = ondemand/" /etc/php/8.1/fpm/pool.d/www.conf
