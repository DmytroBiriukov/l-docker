#!/bin/bash

echo "Install a few prerequisite packages"
sudo apt update && apt install apt-transport-https ca-certificates curl git software-properties-common


if ! [ -x "$(command -v docker)" ]; then
    echo "Add the GPG key for the official Docker repository to your system"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Add docker repo to app sources"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" && sudo apt update

    echo "Make sure you are about to install from the Docker repo instead of the default Ubuntu repo"
    apt-cache policy docker-ce

    echo "Install docker"
    sudo apt install docker-ce
fi

echo "Check that docker daemon is running"
sudo systemctl status docker

echo "To avoid typing sudo whenever you run the docker command, add your username to the docker group"
sudo usermod -aG docker ${USER}

echo "Apply executable permissions for docker-compose install script"
sudo chmod +x install-docker-compose.sh

echo "Apply the new group membership, this command will exit you from this script, and"
echo -e "\e[31m you have to launch install-docker-compose.sh now"

su - ${USER}