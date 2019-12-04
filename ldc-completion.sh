#!/bin/bash

COMMANDS_FILE="./docker/command-list.txt"
read -d $'\x04' COMMANDS < "$COMMANDS_FILE"

complete -W "$COMMANDS" ldc