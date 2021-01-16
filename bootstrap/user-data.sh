#!/bin/bash

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-
# Open STDOUT as $LOG_FILE file for read and write.
exec 1<>/root/ec2-init.log
# Redirect STDERR to STDOUT
exec 2>&1

apt update
apt install apache2 php -y
mkdir -p /home/site-web/www

EC2_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
touch /home/site-web/www/index.html
echo "
<html>
    <head>
        <title>$EC2_IPV4</title>
    </head>

    <body>
        <h1><b>Bienvenue sur le site de Tech-Zone.com.</b></h1>
        $EC2_IPV4
    </body>
</html>" > /home/site-web/www/index.html

cd /etc/apache2/sites-available/

touch /etc/apache2/sites-available/techzone.com.conf
echo "
<VirtualHost *:80>
    ServerName www.tech-zone.com

    ServerAdmin webmaster@tech-zone.com
    DocumentRoot /home/site-web/www/

    <Directory /home/site-web/www/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/techzone.com.conf

a2dissite 000-default.conf
systemctl reload apache2
a2ensite techzone.com.conf
systemctl reload apache2
