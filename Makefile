include .env

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


### Workspace
bash:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app bash

### MySQL -u root  -p root
mysql:
	@docker-compose -f ${DOCKER_CONFIG} exec mysql mysql -u${DB_ROOT_USERNAME} -p${DB_ROOT_PASSWORD}

mysqldump:	
	@docker-compose -f ${DOCKER_CONFIG} exec mysql mysqldump ${DB_DATABASE} -u ${DB_USERNAME} -p  --result-file=$(shell date -d "$xx day" -u +%Y-%m-%d)-${DB_DATABASE}.sql

### Composer
composer_install:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app composer install

composer_dump:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app composer dump-autoload

### NPM
npm_install:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} node npm install

npm_run_dev:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} node npm run dev

npm_run_prod:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} node npm run prod

npm_run_watch:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} node npm run watch

### artisan
art_config_clear: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan config:clear

art_cache_clear: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan cache:clear

art_up: 
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan up

art_down:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan down

art_key:
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan key:generate

art_fresh: # refresh the database and run all database seeds
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan migrate:fresh --seed

art_test: # run all tests
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php vendor/bin/phpunit

art_create_controller: # create controller name=[controllerName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan make:controller $(name)

art_create_model: # create model name=[modelName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan make:model Models/$(name) -m

art_create_seeder: # create seeder name=[seederName]
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} app php artisan make:seeder $(name)TableSeeder

### connect services
### nodejs
connect_node: # node command line
	@docker-compose -f ${DOCKER_CONFIG} exec -u www -w ${NGINX_DOCUMENT_ROOT} node sh
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
