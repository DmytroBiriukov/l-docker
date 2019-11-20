# L-DOCKER

L-DOCKER is a set of docker containers acompained with usefull scripts to dockerize your laravel project. This makes deployment quickier, easier and more realiable. L-DOCKER is flexible to be set up for development, test, and production stages.

## Start new or dockerize existing Laravel project 

Dockerized project will have quite simple folder structure, consisted `docker` folder (to hold containers), and  `laravel` folder (for Laravel project). To transform your existing laravel project into dockerized project just move it into `laravel` folder.  

There are several `docker-compose` files for local (developer computer), development (dev-server) , and production (prod-server) configuration. 

## Deployment

### Install tools

Connect to deployment server. Just before install tools, lets generate public key.
> cd ~/
> mkdir .ssh
> cd ~/.ssh && ls -l
> ssh-keygen -b 4096

Now you've got `id-rsa.pub` public key to specify on `github`, and for your convinience, run this command from your machine:

> cat .ssh/id_rsa.pub | ssh deployment_user__@deployment_server_host__ 'cat >> .ssh/authorized_keys'

#### Install docker and docker-compose

In order to dockerize you Laravel project you have to install `docker` itself along with `docker-compose` on your computer or server.
Also `make` is needed to run commands from Makefile. 

We prepared `install-docker.sh` and `install-docker-composer.sh` scripts that execute installation and configuration commands for Ubuntu (Bionic). You may edit this scripts to install on other linux. Just don't forget to make `install-docker.sh` executable.

> sudo chmod +x install-docker.sh

Then run `install-docker.sh` and `install-docker-composer.sh` one by one. The first script will make the second executable, but you still have to run both scripts. 

### Docker .env

Copy .env.template file into .env and change environment parameters.
For development sever comment off DOCKER_CONFIG=docker-compose-dev.yml , instead, comment DOCKER_CONFIG=docker-compose.yml .
For production sever comment off DOCKER_CONFIG=docker-compose-prod.yml , instead, comment DOCKER_CONFIG=docker-compose.yml .

Please, note, there are several differences among `local`, `development` and `production` configurations of docker containers, such as webserver ports, that may be specified.  

### Configure containers

#### PHP

You may configure PHP according your requirements. In `app` container's Dockerfile you will find some extra PHP configs:

* `memory_limit` is set to 4092M
* `max_execution_time` is set to 0 (infinity)

Also there are some configuration changes made in `docker-ep-extra.sh`.
* `xdebug` is set on port `DOCKER_XDEBUG_PORT`

#### NGINX

To change NGINX configuration for your Laravel project, just edit `default.conf` from `docker\nginx\conf-dev` or `docker\nginx\conf-prod` folder.

**Note, you have to specify correct `server_name` and `root` parameters in these config files.**

#### MYSQL

Your database will be stored in `./docker/mysql/databases` folder.
To initialize your database from `.sql` dump file, just copy dump file into  `./docker/mysql/initdb` folder.

#### Supervisorctl

To manage Laravel queues with `supervisorctl` you have to specify configuration file for each queue, and store it in `./docker/supervisor/supervisord.d`. In this forlder you will find `default.conf` for default queue, as well as 2 extra configuration files (you may use these 2 files as configuration examples or just delete them). 
Don't forget to specify correct path for `php artisan queue` command in configuration files (replace `l-docker` with you project name). 

All supervisor logs are recommended to store in `./docker/supervisor/logs` folder that is available for host.

**Note, as far supervisor has separate container all neccessary php extentions should be installed in order to perform certain jobs in queues.**

There are several supervisorctl commands available through `Makefile`^

> make supervisor restart_all 

> make supervisor stop_all

> make supervisor update_all

### Build and up docker containers

In order to use services (`nginx` and `mysql`) and package managers (`composer` and `npm`) you have to build and run docker containers. To simplify command line interface with `docker-compose`, we included `Makefile` with various targets.

* So, firstly, you have to build all containers by running `docker-compose build`, or the following command:

> make build

It may take a long time at first, as far images showld be downloaded, but it is much faster next times. 

* When containers are built, you have to start them `docker-compose up -d`, or throught `Makefile` target:

> make up

* To print out containers run `docker-compose ps`, or the following command:  

> make ps

### Deployment on production server

#### Manage HTTPS for production server

For production environment we should obtain Let's Encrypt certificate to manage https. Just run `init-letsencrypt.sh` script from the project root directory.

### Setup Laravel project

* Laravel .env

Copy `./laravel/.env.template` file into `./laravel/.env` and change environment parameters.
For development server you should change APP_ENV=local to APP_ENV=development,  and  APP_DEBUG=true to APP_DEBUG=false .
For production server you should change APP_ENV=local to APP_ENV=production ,  and  APP_DEBUG=true to APP_DEBUG=false .

* create folders `framework/cache`, `framework/sessions` and `framework/views` inside `laravel/storage/`

Change database connection settings in Laravel `.env` file:

```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=l-docker
DB_USERNAME=l-docker
DB_PASSWORD=secret
```

#### Install PHP dependancies

> make composer_install

#### Generate key

> make art_key

#### Make migrations and seed database

> make art_fresh

#### Install JS dependancies

> make npm_install
> make npm_run_dev
> make npm_run_prod

#### Laravel scheduler

In order to use Laravel scheduler, the necessary entry was added to `Cron` on `app` container. It looks like

```
* * * * * php /var/www/l-docker/artisan schedule:run >> /dev/null 2>&1
```

while `l-docker` is replaced by you project name (`PROJECT_ID`) taken from `.env'.





### Helper script

To ease your work with dockerized laravel project we prepared helper script `ld.sh`.
Also there is autocompletion for this script, you have to anable autocomletion by running

```
source ld-completion.sh
```

Dont forget to make `ld.sh` executable 

```
sudo chmod +x ld.sh
```

