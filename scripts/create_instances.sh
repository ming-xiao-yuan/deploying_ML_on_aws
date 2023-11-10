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
terraform output worker_ips

# Capture the IP addresses in JSON format
WORKER_IPS_JSON=$(terraform output -json worker_ips)

# Fetch the orchestrator public DNS
ORCHESTRATOR_DNS=$(terraform output -raw orchestrator_public_dns)

# Function to check if the orchestrator is up and running
check_orchestrator() {
  curl -m 5 -s "http://$ORCHESTRATOR_DNS/health_check" > /dev/null
  return $?
}

# Poll the orchestrator service until it's up or the timeout is reached
echo "Waiting for the orchestrator service to start..."
SECONDS=0
TIMEOUT=300 # Set a 5-minute timeout
while ! check_orchestrator; do
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
