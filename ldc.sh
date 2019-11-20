#!/bin/bash

source .env
echo -e "\e[39mLaravel project : \e[33m"$PROJECT_ID
echo -e "\e[39mEnvironment : \e[33m"$DOCKER_ENVIRONMENT


### Allowed commands
COMMANDS_FILE="./docker/command-list.txt"
read -d $'\x04' COMMANDS < "$COMMANDS_FILE"

function show_allowed_commands() {    
    echo -e "\e[31m Allowed commands are:"    
    echo -e "\e[93m "$COMMANDS"\e[39m"
}

### Refresh project
function refresh_project() {
    echo -e "\e[39mThis script will refresh laravel project, you will be asked:"

    declare -a StringArray=("Would you like to refresh DATABASE? [Y/n] " "Would you like to delete MEDIA files? [Y/n] " "Would you like to delete CACHE/SESSION/VIEWS files? [Y/n] " "Would you like to delete LOGS? [Y/n] ")

    # Read the array values with space
    for val in "${StringArray[@]}"; do
    echo $val
    done

    echo -e "\e[39mSo here we are go!"
    # php artisan down
    docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan down

    read -r -p "Would you like to refresh DATABASE? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan migrate:fresh --seed
    fi

    read -r -p "Would you like to delete MEDIA files? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        sudo rm -R ./laravel/public/media/*
        sudo rm -R ./laravel/storage/medialibrary/temp/*
    fi

    read -r -p "Would you like to delete CACHE/SESSION/VIEWS files? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan config:clear
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan cache:clear
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan view:clear
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan route:clear
    fi

    read -r -p "Would you like to delete LOGS? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        sudo rm -R ./laravel/storage/logs/*
        sudo rm -R ./docker/supervisor/logs/*
    fi

    read -r -p "Would you like to restart SUPERVISOR? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec supervisor supervisorctl restart all
    fi

    # php artisan up
    docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan up
}

### Test containers
function test_containers() {
    containers="${PROJECT_ID}_app ${PROJECT_ID}_nginx ${PROJECT_ID}_mysql ${PROJECT_ID}_node ${PROJECT_ID}_supervisor"
    for container_name in $containers
    do
        if [ $(docker inspect -f '{{.State.Running}}' $container_name) = "true" ]; then
            echo "$container_name - OK, it is running";
        else
            echo "$container_name - FAILURE, it is not running";
        fi
    done
}


if [ -z "$1" ]; then
    echo -e "\e[31mNo command supplied!"    
    show_allowed_commands
    exit 1
else
    echo -e "\e[39mCommand : \e[33m"$1
    echo -e "\e[39m"   
    
    DOCKER_COMPOSE_FILE_FLAGS="-f docker-compose.yml"

    case $DOCKER_ENVIRONMENT in
        local)
            DOCKER_COMPOSE_FILE_FLAGS="-f docker-compose.yml -f docker-compose-local.yml"
            ;;
        development)
            DOCKER_COMPOSE_FILE_FLAGS="-f docker-compose.yml -f docker-compose-dev.yml"
            ;;        
        production)
            DOCKER_COMPOSE_FILE_FLAGS="-f docker-compose.yml -f docker-compose-prod.yml"
            ;;
        *)
            echo -e "\e[31mOnly [local|development|production] environments are supported!"
            exit 1
            ;;    
    esac

    PARAMETER_REQUIRED="art-make-controller art-make-model art-make-migration art-make-seeder art-queue-run"

    if [[ " $PARAMETER_REQUIRED " =~ .*\ $1\ .* ]]; then
        if [ -z "$2" ]; then            
            echo -e "\e[31mSecond parameter is required!" 
            exit 1
        fi
    fi 

    case "$1" in   
        refresh-project)     
            refresh_project
            ;;
        build)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS build
            ;;
        start)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS start
            ;; 
        stop)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS stop
            ;;                       
        up)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS up -d
            echo ""
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS ps
            ;;         
        down)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS down
            ;;
        down-volume)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS down -v
            ;;            
        ps)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS ps
            ;;         
        docker-stop-all)
        	docker stop $(docker ps -a -q)
            ;;
        docker-remove-all)
	        docker rm $(docker ps -a -q)
            ;;
        test-containers)
            test_containers
            ;;
        bash)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app sh
            ;;
#mysql            
        mysql)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec mysql mysql -u$DB_ROOT_USERNAME -p$DB_ROOT_PASSWORD
            ;;
        mysqldump)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec mysql mysqldump $DB_DATABASE -u $DB_USERNAME -p  --result-file=$(shell date -d "$xx day" -u +%Y-%m-%d)-$DB_DATABASE.sql
            ;;
        mysql-import)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec mysql mysql -u$DB_ROOT_USERNAME -p$DB_ROOT_PASSWORD $DB_DATABASE < $DB_DATABASE.sql;
            ;;
        mysql-bash)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec mysql bash
            ;;
#composer            
        composer-install)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app composer install
            ;;
        composer-update)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app composer update
            ;;
        composer-require)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app composer require ${package}
            ;;
        composer-dump)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app composer dump-autoload
            ;;
#npm
        npm-install)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm install
            ;;
        npm-update)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm update
            ;;
        npm-run-dev)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm run dev
            ;;
        npm-run-prod)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm run prod
            ;;
        npm-run-watch)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm run watch
            ;;
        npm-clear)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node npm cache clear --force
            ;;
### php artisan
        art-config-clear)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan config:clear
            ;;
        art-cache-clear) 
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan cache:clear
            ;;
        art-view-clear)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan view:clear
            ;;
        art-route-clear) 
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan route:clear
            ;;
        art-up)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan up
            ;;
        art-down)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan down
            ;;
        art-key)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan key:generate
            ;;
        art-fresh) # refresh the database and run all database seeds
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan migrate:fresh --seed
            ;;
        art-make-controller) # create controller name=[controllerName]
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan make:controller $(name)
            ;;
        art-make-model) # create model name=[modelName]
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan make:model Models/$(name) -m
            ;;
        art-make-migration) # make art_make_migration name=[migrationName]
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan make:migration $(name)
            ;;
        art-make-seeder) # create seeder name=[seederName]
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan make:seeder $(name)TableSeeder
            ;;
        art-test) # run all tests
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php vendor/bin/phpunit
            ;;
        art-queue-run) # usage example:  make art_queue_run queue=akeneo
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT app php artisan queue:work --queue=${queue} --tries=3 --timeout=0
            ;;
### Connect certain services
        connect-node)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -u www -w $NGINX_DOCUMENT_ROOT node sh
            ;;
        connect-nginx)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec -w $NGINX_DOCUMENT_ROOT nginx sh
            ;;
### Rebuild certain services
        rebuild-app)
            docker-compose up -d --no-deps --build app
            ;;
        rebuild-mysql)
            docker-compose up -d --no-deps --build mysql
            ;;
        rebuild-node)
            docker-compose up -d --no-deps --build node
            ;;
        rebuild-supervisor)
            docker-compose up -d --no-deps --build supervisor
            ;;
### NGINX
        nginx-reload)
            docker-compose exec nginx nginx -s reload
            ;;
        nginx-test)
            docker-compose exec nginx nginx -t
            ;;
### Supervisor
        supervisorctl-restart-all)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec supervisor supervisorctl restart all
            ;;
        supervisorctl-stop-all)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec supervisor supervisorctl stop all
            ;;
        supervisorctl-update-all)
            docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec supervisor supervisorctl update all
            ;;
### Cron            
        cron_l)
	        docker-compose $DOCKER_COMPOSE_FILE_FLAGS exec app crontab -l
            ;;
        *)            
            echo -e "\e[31mWrong command supplied!" 
            show_allowed_commands
            exit 1
            ;;
    esac    
fi