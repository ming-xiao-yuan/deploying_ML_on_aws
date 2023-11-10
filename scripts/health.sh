# Function to check if the orchestrator is up and running
check_orchestrator() {
  http_status_code=$(curl -m 5 -s -o /dev/null -w "%{http_code}" "http:// 52.203.142.231/health_check")
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