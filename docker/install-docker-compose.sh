#!/bin/bash

echo "Confirm that your user is now added to the docker group"
id -nG

if ! [ -x "$(command -v docker-compose)" ]; then
    echo "Install docker-compose"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    echo "Apply executable permissions"
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo "Now you may check whether you can access and download images from Docker Hub"
docker run hello-world

echo "Display version"
docker-compose --version

### Here you may insert any download commands you need
### than you may copy these sources into `app` container
#echo "Downloading sources"
#sudo curl -L -o app/source/wkhtmltopdf.tar.xz https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

echo "Enabling Helper ldc script"
cd ../
sudo chmod +x ldc.sh
sudo chmod +x ldc-completion.sh
source ldc-completion.sh

if ! [ -x "$(command -v ldc)" ]; then
    echo -e 'function ldc() {\n  source "${PWD}/ldc-completion.sh"\n  ${PWD}/ldc.sh "$@"\n}' >> ~/.bashrc
    source ~/.bashrc
else
    echo "ldc helper already installed"
fi