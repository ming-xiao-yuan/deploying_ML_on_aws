import concurrent.futures
import os
import requests


# Function to make a request
def make_request(url):
    payload = {"payload": "dummy payload"}
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return f"URL: {url}, Status Code: {response.status_code}"


# Read the Orchestrator DNS from environment variable
orchestrator_dns = os.getenv("ORCHESTRATOR_DNS")
if not orchestrator_dns:
    raise ValueError("Orchestrator DNS not provided in environment variables")

print("Orchestrator DNS: ", orchestrator_dns)

# URL to request
url = f"http://{orchestrator_dns}/new_request"

# Set the number of concurrent requests
num_concurrent_requests = 20

# Create a list of the same URL to be hit concurrently
urls = [url] * num_concurrent_requests

# Use ThreadPoolExecutor to parallelize the requests
with concurrent.futures.ThreadPoolExecutor(
    max_workers=num_concurrent_requests
) as executor:
    # Map the make_request function to the list of URLs
    results = list(executor.map(make_request, urls))

# Print the results
for result in results:
    print(result)
