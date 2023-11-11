#!/bin/bash

# Access the env variables
source env_vars.sh

# Pulling requests_app's image
docker pull mingxiaoyuan/requests:latest

echo -e "\nSending requests...\n"

# Running the requests_app's container with Orchestrator DNS
docker run -e ORCHESTRATOR_DNS="$ORCHESTRATOR_DNS" mingxiaoyuan/requests:latest

# Showing the requests_app's prints
docker logs -f requests_app_latest

# Removing the requests_app's container
echo -e "Removing the docker container...\n"
docker rm requests_app_latest
