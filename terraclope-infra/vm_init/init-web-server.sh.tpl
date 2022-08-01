#!/bin/sh
#Give root right
sudo su

#Update system
apt-get update -y && sudo apt-get upgrade -y

#Install Apache2 for Web Server usage
apt install apache2 -y

#Restart apache2
Systemctl restart apache2

#install free front-end template for fun :)
wget https://www.free-css.com/assets/files/free-css-templates/download/page281/koppee.zip
apt install unzip -y
unzip koppee.zip
rm /var/www/html/index.html
mv ./coffee-shop-html-template/* /var/www/html/
cd /var/www/html

#Change templace front :)
sed -i 's/KOPPEE/TERRACLOPE/g' index.html
sed -i 's/We Have Been Serving/Welcome to your/g' index.html
sed -i 's/COFFEE/TERRACLOPE/g' index.html
sed -i 's/SINCE 1950/site Template/g' index.html

#leave root
exit