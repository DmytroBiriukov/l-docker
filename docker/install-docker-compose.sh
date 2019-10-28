#!/bin/bash

echo "Confirm that your user is now added to the docker group"
id -nG

echo "Install docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "Apply executable permissions"
sudo chmod +x /usr/local/bin/docker-compose

echo "Now you may check whether you can access and download images from Docker Hub"
docker run hello-world

echo "Display version"
docker-compose --version

echo "Display git and make versions"
git --version make -version
