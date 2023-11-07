#!/bin/bash

# Access the env variables
source env_vars.sh

echo -e "Creating instances...\n"

cd ../infrastructure

# Initilize Terraform
terraform.exe init

# Applies the the main.tf
terraform.exe apply -auto-approve -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -var="AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"

echo -e "Everything was created successfully\n"
echo -e "-----------\n"
