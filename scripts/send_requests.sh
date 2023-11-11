#!/bin/bash

# Access the env variables
source env_vars.sh

# Pulling requests_app's image
docker pull mingxiaoyuan/requests:latest

echo -e "\nSending requests...\n"

# Running the requests_app's container with Orchestrator DNS
docker run --rm -e ORCHESTRATOR_DNS="$ORCHESTRATOR_DNS" mingxiaoyuan/requests:latest