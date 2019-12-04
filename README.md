# L-DOCKER

L-DOCKER is a set of docker containers acompained with usefull scripts to dockerize your laravel project. This makes deployment quickier, easier and more realiable. L-DOCKER is flexible to be set up for development, test, and production stages.

## Start new or dockerize existing Laravel project 

Dockerized project will have quite simple folder structure, consisted `docker` folder (to hold containers), and  `laravel` folder (for Laravel project). To transform your existing laravel project into dockerized project just move it into `laravel` folder.  

There are several `docker-compose` files for local (developer computer), development (dev-server), and production (prod-server) configuration. 

## Deployment

### Install tools

Connect to deployment server. Just before install tools, lets generate public key.
> cd ~/
> mkdir .ssh
> cd ~/.ssh && ls -l
> ssh-keygen -b 4096

Now you've got `id-rsa.pub` public key to specify on `github`, and for your convinience, run this command from your machine:

> cat .ssh/id_rsa.pub | ssh deployment_user__@deployment_server_host__ 'cat >> .ssh/authorized_keys'

### Install docker and docker-compose

In order to dockerize you Laravel project you have to install `docker` itself along with `docker-compose` on your computer or server.
Also `make` is needed to run commands from Makefile. 

We prepared `install-docker.sh` and `install-docker-composer.sh` scripts that execute installation and configuration commands for Ubuntu (Bionic). You may edit this scripts to install on other linux. Just don't forget to make `install-docker.sh` executable.

> sudo chmod +x install-docker.sh

Then run `install-docker.sh` and `install-docker-composer.sh` one by one. The first script will make the second executable, but you still have to run both scripts. 

### Helper script

To ease your work with dockerized laravel project we prepared helper script `ldc.sh`.
Also there is autocompletion for this script. 

Run `ldc` to list all available commands. 

### Docker .env

Copy .env.template file into .env and change environment parameters.
Change `DOCKER_ENVIRONMENT` to specify appropriate environment (`local` for local development, `development` for development sever, or `production` for production server). 
Please, note, there are several differences among `local`, `development` and `production` configurations of docker containers, such as webserver ports, that may be specified. You may investigate those differences in docker-compose `.yml` files.  

### Configure containers

#### PHP

You may configure PHP according your requirements. In `app` container's Dockerfile you will find some extra PHP configs:

* `memory_limit` is set to 4092M
* `max_execution_time` is set to 0 (infinity)

Also there are some configuration changes made in `docker-ep-extra.sh`.
* `xdebug` is set on port `DOCKER_XDEBUG_PORT`

#### NGINX

To change NGINX configuration for your Laravel project, just edit `default.conf` from `docker\nginx\conf-dev` or `docker\nginx\conf-prod` folder.

#### MYSQL

Your database will be stored in `./docker/mysql/databases` folder.
To initialize your database from `.sql` dump file, just copy dump file into  `./docker/mysql/initdb` folder.

#### Supervisorctl

To manage Laravel queues with `supervisorctl` you have to specify configuration file for each queue, and store it in `./docker/supervisor/supervisord.d`. In this forlder you will find `default.conf` for default queue, as well as 2 extra configuration files (you may use these 2 files as configuration examples or just delete them). 

All supervisor logs are recommended to store in `./docker/supervisor/logs` folder that is available for host.

**Note, as far supervisor has separate container all neccessary php extentions should be installed in order to perform certain jobs in queues.**

There are several supervisorctl commands available through `ldc`:

> ldc supervisorctl-restart-all 

> ldc supervisorctl-stop-all

> ldc supervisorctl-update-all


### Build and up docker containers

In order to use services (`nginx` and `mysql`) and package managers (`composer` and `npm`) you have to build and run docker containers. To simplify command line interface with `docker-compose`, we included various command nto `ldc` helper script.

* So, firstly, you have to build all containers by running `docker-compose build`, or the following command:

> ldc build

It may take a long time at first, as far images showld be downloaded, but it is much faster next times. 

* When containers are built, you have to start them `docker-compose up -d`, or throught `ldc` helper:

> ldc up

* To print out containers run `docker-compose ps`, or the following command:  

> ldc ps

### Deployment on production server

#### Manage HTTPS for production server

For production environment we should obtain Let's Encrypt certificate to manage https. Just run `init-letsencrypt.sh` script from the `docker` directory.

### Setup Laravel project

#### Laravel .env

Copy `./laravel/.env.template` file into `./laravel/.env` and change environment parameters.
For development server you should change `APP_ENV=local` to `APP_ENV=development`,  and  `APP_DEBUG=true` to `APP_DEBUG=false`.
For production server you should change `APP_ENV=local` to `APP_ENV=production`,  and  `APP_DEBUG=true` to `APP_DEBUG=false` .

#### Change database connection settings in Laravel `.env` file:

```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=l-docker
DB_USERNAME=l-docker
DB_PASSWORD=secret
```
**Note, DB_DATABASE and DB_USERNAME shoud correspond with those specified in docker .env file** 

#### Install PHP dependancies

Run `composr install` into `app` container by:

> ldc composer-install

#### Generate key

> ldc art-key

#### Make migrations and seed database

> ldc art-fresh

#### Install JS dependancies

> ldc npm-install
> ldc npm-run-dev
> ldc npm-run-prod

#### Laravel scheduler

In order to use Laravel scheduler, the necessary entry was added to `Cron` on `app` container. It looks like

```
* * * * * php /var/www/l-docker/artisan schedule:run >> /dev/null 2>&1
```

### IDE settings

If you prefere vscode, you may find useful `launch.json` settings for xdebug (Dockerized XDebug).



