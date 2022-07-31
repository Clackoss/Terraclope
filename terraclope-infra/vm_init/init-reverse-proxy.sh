#!/bin/sh

# Update packages and Upgrade system
echo "Apt update & upgrade"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing nginx for reverse proxy usage"
sudo apt-get install nginx