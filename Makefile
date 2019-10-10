include .env

### docker-compose commands
up: # create and start containers
	@docker-compose -f ${DOCKER_CONFIG} up -d

down: # stop and destroy containers
	@docker-compose -f ${DOCKER_CONFIG} down

down-volume: #  WARNING: stop and destroy containers with volumes
	@docker-compose -f ${DOCKER_CONFIG} down -v

start: # start already created containers
	@docker-compose -f ${DOCKER_CONFIG} start

stop: # stop containers, but not destroy
	@docker-compose -f ${DOCKER_CONFIG} stop

ps: # show started containers and their status
	@docker-compose -f ${DOCKER_CONFIG} ps

build: # build all dockerfile, if not built yet
	@docker-compose -f ${DOCKER_CONFIG} build

### docker commands
docker_stop_all:
	@docker stop $(docker ps -a -q)

docker_remove_all:
	@docker rm $(docker ps -a -q)

### Workspace
bash:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app sh

### MySQL -u root  -p root
mysql:
	@docker-compose -f ${DOCKER_CONFIG} exec mysql mysql -u${DB_ROOT_USERNAME} -p${DB_ROOT_PASSWORD}

mysqldump:
	@docker-compose -f ${DOCKER_CONFIG} exec mysql mysqldump ${DB_DATABASE} -u ${DB_USERNAME} -p  --result-file=$(shell date -d "$xx day" -u +%Y-%m-%d)-${DB_DATABASE}.sql

mysql_import:
	@docker-compose -f ${DOCKER_CONFIG} exec mysql mysql -u${DB_ROOT_USERNAME} -p${DB_ROOT_PASSWORD} ${DB_DATABASE} < ${DB_DATABASE}.sql;

### Composer
composer_install:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app composer install

composer_update:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app composer update

composer_require:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app composer require ${package}

composer_dump:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app composer dump-autoload

### NPM
npm_install:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm install

npm_update:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm update

npm_run_dev:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm run dev

npm_run_prod:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm run prod

npm_run_watch:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm run watch

npm_clear:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node npm cache clear --force

### php artisan
art_config_clear:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan config:clear

art_cache_clear: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan cache:clear

art_view_clear:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan view:clear

art_route_clear: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan route:clear

art_up: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan up

art_down:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan down

art_key:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan key:generate

art_fresh: # refresh the database and run all database seeds
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan migrate:fresh --seed

art_make_controller: # create controller name=[controllerName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan make:controller $(name)

art_make_model: # create model name=[modelName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan make:model Models/$(name) -m

art_make_migration: # make art_make_migration name=[migrationName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan make:migration $(name)

art_make_seeder: # create seeder name=[seederName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan make:seeder $(name)TableSeeder

art_test: # run all tests
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php vendor/bin/phpunit

art_queue_run: # usage example:  make art_queue_run queue=akeneo
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} app php artisan queue:work --queue=${queue} --tries=3 --timeout=0

### connect services
### nodejs
connect_node: # node command line
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT}/${PROJECT_ID} node sh
### nginx
connect_nginx: # nginx command line
	@docker-compose -f ${DOCKER_CONFIG} exec -w /www nginx sh
### MySQL
connect_db: # database command line
	@docker-compose -f ${DOCKER_CONFIG} exec mysql bash

### NGINX
nginx_reload:
	@docker-compose exec nginx nginx -s reload

nginx_test:
	@docker-compose exec nginx nginx -t

### Rebuild certain services
rebuild_app:
	@docker-compose up -d --no-deps --build app

rebuild_mysql:
	@docker-compose up -d --no-deps --build mysql

rebuild_node:
	@docker-compose up -d --no-deps --build node

rebuild_supervisor:
	@docker-compose up -d --no-deps --build supervisor

### Supervisor
supervisorctl_restart_all:
	@docker-compose -f ${DOCKER_CONFIG} exec supervisor supervisorctl restart all	

supervisorctl_stop_all:
	@docker-compose -f ${DOCKER_CONFIG} exec supervisor supervisorctl stop all