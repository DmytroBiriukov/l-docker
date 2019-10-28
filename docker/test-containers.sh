#!/bin/bash

# Run all command from project root directory
cd ..

containers="l-docker_app l-docker_nginx l-docker_mysql l-docker_node l-docker_supervisor"

for container_name in $containers
do
        if [ $(docker inspect -f '{{.State.Running}}' $container_name) = "true" ];
        then
                echo "$container_name - OK, it is running";
        else
                echo "$container_name - FAILURE, it is not running";
        fi
done