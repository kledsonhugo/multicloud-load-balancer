#!/bin/bash

echo "Update/Install required OS packages"
sudo apt-get update -y
sudo apt-get install -y apache2 wget php php-mysql php-json php-cli php-dev telnet tree git

echo "Deploy PHP info app"
cd /tmp
git clone https://github.com/kledsonhugo/app-dynamicsite
cp /tmp/app-dynamicsite/phpinfo.php /var/www/html/index.php
sudo rm /var/www/html/index.html