#!/bin/sh
#gives root
sudo su

# Update packages and Upgrade system
apt-get update -y && sudo apt-get upgrade -y

#echo "Installing nginx for reverse proxy usage"
apt-get install nginx -y

#Configure Nginx for rever proxy usage
unlink /etc/nginx/sites-enabled/default

cd /etc/nginx/sites-available/
echo "server {
listen 80;
location / {
proxy_pass http://${web_server_ip};
}
}" > terraclope.conf

ln -s /etc/nginx/sites-available/terraclope.conf /etc/nginx/sites-enabled/terraclope.conf

#restart nginx
service nginx restart

#leave root
exit
