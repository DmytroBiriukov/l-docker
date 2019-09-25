# MD-PLATFORM

## Deployment

### Clone repository
[GitHub](https://github.com/voroshilov-dima/md-platform)
- dont forget that development branch is named **develop** -
- and production branch is **master** 

### Docker .env

Copy .env.template file into .env and change environment parameters.
For development sever comment off DOCKER_CONFIG=docker-compose-dev.yml , instead, comment DOCKER_CONFIG=docker-compose.yml .
For production sever comment off DOCKER_CONFIG=docker-compose-prod.yml , instead, comment DOCKER_CONFIG=docker-compose.yml .

Please, note, there are several differences among `local`, `development` and `production` configurations of docker containers, such as webserver ports, that may be specified.  

### Build and up docker containers

In order to use services (`nginx` and `mysql`) and package managers (`composer` and `npm`) you have to build and run docker containers. To simplify command line interface with `docker-compose`, we included `Makefile` with various targets.

* So, firstly, you have to build all containers by running `docker-compose build`, or the following command:

> make build

It may take a long time at first, as far images showld be downloaded, but it is much faster next times. 

* When containers are built, you have to start them `docker-compose up -d`, or throught `Makefile` target:

> make up

* To print out containers run `docker-compose ps`, or the following command:  

> make ps

### Manage HTTPS

For production environment we should obtain Let's Encrypt certificate to manage https. Just run `init-letsencrypt.sh` script from the project root directory.

### Setup Laravel project

* Laravel .env

Copy ./laravel/.env.template file into ./laravel/.env and change environment parameters.
For development server you should change APP_ENV=local to APP_ENV=development,  and  APP_DEBUG=true to APP_DEBUG=false .
For production server you should change APP_ENV=local to APP_ENV=production ,  and  APP_DEBUG=true to APP_DEBUG=false .

* create folders `framework/cache`, `framework/sessions` and `framework/views` inside `laravel/storage/`

* install PHP dependancies

> make composer_install

* generate key

> make art_key

* make migrations and seed database

> make art_fresh

* install JS dependancies

> make npm_install
> make npm_run_dev
> make npm_run_prod

### Install tools

#### Install docker on Ubuntu 18.04 (bionic)

* install a few prerequisite packages

> sudo apt update && apt install apt-transport-https ca-certificates curl git make software-properties-common

* add the GPG key for the official Docker repository to your system

> curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

* add docker repo to app sources

> sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" && sudo apt update

* make sure you are about to install from the Docker repo instead of the default Ubuntu repo

> apt-cache policy docker-ce

* install

> sudo apt install docker-ce

* check that docker daemon running

> sudo systemctl status docker

* to avoid typing sudo whenever you run the docker command, add your username to the docker group

> sudo usermod -aG docker ${USER}

* apply the new group membership

> su - ${USER}

* confirm that your user is now added to the docker group

> id -nG

* Now you may check whether you can access and download images from Docker Hub 

> docker run hello-world

* Display git and make versions

> git --version
> make -version

#### Install docker-compose on Ubuntu 18.04 (bionic)

* download Docker Compose binary

> sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

* apply executable permissions

> sudo chmod +x /usr/local/bin/docker-compose

* display version

> docker-compose --version

## CI with Jenkins

### Prepare Jenkins server

* Connect Jenkins server 

* Add deployment_server key to Jenkins server

> cat ~/.ssh/id_rsa.pub | ssh deployment_user__@deployment_server_host__ 'cat >> .ssh/authorized_keys'

* Copy `jenkins-laravel.sh` and `md-platform.conf` files into `/usr/local/bin/jenkins/` and `/usr/local/bin/jenkins//config/laravel/` folders on Jenkins server.

### Configure task

* Log in https://jenkins.ensocore.com/ and add task

* In `Source Code Management` specify repository and branches:

> origin/master

> origin/develop

* In `Build Triggers` section, check `Poll SCM`. Set cron schedule for every 2 minutes `H/2 * * * *`.

* In `Build` section, select `Execute shell`, and specify command:

> /bin/sh /usr/local/bin/jenkins/jenkins-laravel.sh md-platform.conf "${GIT_BRANCH}"

See [tutorial](https://www.shift8web.ca/2018/02/use-jenkins-git-automate-code-pushes-laravel-site/) for further details.
