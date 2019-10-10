#!/bin/bash

echo "This script will refresh laravel project, you will be asked:\n"

declare -a StringArray=("Would you like to refresh DATABASE? [Y/n] " "Would you like to delete MEDIA files? [Y/n] " "Would you like to delete CACHE/SESSION/VIEWS files? [Y/n] " "Would you like to delete LOGS? [Y/n] ")

# Read the array values with space
for val in "${StringArray[@]}"; do
  echo $val
done

echo "So here we are go!\n"

make art_down

read -r -p "Would you like to refresh DATABASE? [Y/n]" response
response=${response,,}
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    make art_fresh
fi

read -r -p "Would you like to delete MEDIA files? [Y/n]" response
response=${response,,}
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    sudo rm -R laravel/public/media/*
    sudo rm -R laravel/storage/medialibrary/temp/*
fi

read -r -p "Would you like to delete CACHE/SESSION/VIEWS files? [Y/n]" response
response=${response,,}
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    make art_cache_clear
    make art_config_clear
    make art_view_clear   
    make art_route_clear     
    sudo rm -R laravel/storage/framework/cache/*
    sudo rm -R laravel/storage/framework/sessions/*
    sudo rm -R laravel/storage/framework/views/*    
fi

read -r -p "Would you like to delete LOGS? [Y/n]" response
response=${response,,}
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    sudo rm -R laravel/storage/logs/*
    sudo rm -R docker/supervisor/logs/*
fi

read -r -p "Would you like to restart SUPERVISOR? [Y/n]" response
response=${response,,}
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    make supervisorctl_restart_all
fi

make art_up