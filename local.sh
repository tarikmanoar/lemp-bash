#!/usr/bin/env bash

sudo apt update -y -q

//For Php 7.4
sudo apt install -y git php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-sqlite3 php-pgsql

sudo systemctl disable --now apache2
sudo apt-get install nginx

//For Php 8.x
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt install php8.0-fpm nginx
sudo apt install php8.0-{cli,fpm,common,mysql,zip,gd,mbstring,curl,xml,bcmath,sqlite3,pgsql,imagick,imap}
systemctl status php8.0-fpm nginx

//For nodejs

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g npm@latest [ OR ] npm install -g npm@7.20.5

sudo npm install -g jshint



sudo nano /etc/nginx/nginx.conf
    client_max_body_size 100M;
sudo service nginx restart
//Change Php INI also


php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer

composer global require squizlabs/php_codesniffer

composer global require laravel/installer

composer global require cpriego/valet-linux

sudo apt-get install network-manager libnss3-tools jq xsel

valet install

sudo apt install -y mariadb-server --fix-missing

sudo mysql -uroot
    use mysql;
    update user set plugin="" where user="root";
    flush privileges;
    \q

sudo apt install gnome-keyring

//For Dump DB/Export All
mysqldump -u root -p --all-databases > alldb.sql
//For Import
mysql -u root -p < alldb.sql


//Install Unijoy
sudo apt-get install -y ibus-m17n m17n-db ibus-gtk
sudo dpkg -L m17n-db | grep unijoy
ibus-daemon -xdr



//Install PostMan
$ tar -xzf Postman-linux-x64-7.32.0.tar.gz
$ sudo mkdir -p /opt/apps/
$ sudo cp -R Postman /opt/apps/
$ sudo ln -s /opt/apps/Postman/Postman /usr/local/bin/postman
$ postman
$ sudo vim /usr/share/applications/postman.desktop

[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/apps/Postman/app/resources/app/assets/icon.png
Exec="/opt/apps/Postman/Postman"
Comment=Postman Desktop App
Categories=Development;Code;
