#!/bin/bash

# Access the env variables
source env_vars.sh

# Initialize Terraform
echo -e "Creating instances...\n"
cd ../infrastructure

# Initilize Terraform
terraform.exe init

# Apply the Terraform configuration
terraform.exe apply -auto-approve -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -var="AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"

# Output the workers ip
# terraform.exe output worker_ips

# Capture the IP addresses in JSON format
WORKER_IPS_JSON=$(terraform.exe output -json worker_ips)

# Fetch the orchestrator public DNS
ORCHESTRATOR_DNS=$(terraform.exe output -raw orchestrator_public_dns)

# Function to check if the orchestrator is up and running
check_orchestrator() {
  http_status_code=$(curl -m 5 -s -o /dev/null -w "%{http_code}" "http://$ORCHESTRATOR_DNS/health_check")
  echo $http_status_code
}

# Poll the orchestrator service until it's up or the timeout is reached
echo "Waiting for the orchestrator service to start..."
SECONDS=0
TIMEOUT=300 # Set a 5-minute timeout

while true; do
    http_status=$(check_orchestrator)

    if [ "$http_status" -eq 200 ]; then
        echo "Orchestrator service is now available."
        break
    fi

    if [ $SECONDS -ge $TIMEOUT ]; then
        echo "Timeout reached, orchestrator service is not available."
        exit 1
    fi

    sleep 10 # Wait for 10 seconds before trying again
done

# Send the worker IPs to the orchestrator using HTTP POST request
curl -X POST "http://$ORCHESTRATOR_DNS/receive_ips_from_workers" \
    -H "Content-Type: application/json" \
    -d "$WORKER_IPS_JSON"

echo -e "\nWorker IPs sent to the orchestrator successfully."


echo -e "Everything was created successfully\n"
echo -e "-----------\n"
