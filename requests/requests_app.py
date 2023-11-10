import concurrent.futures
import requests

# Function to make a request
def make_request(url):
    payload = {"payload": "dummy payload"}
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    return f"URL: {url}, Status Code: {response.status_code}"

# URL to request
url = "http://3.90.244.135/new_request"

# Set the number of concurrent requests
num_concurrent_requests = 5

# Create a list of the same URL to be hit concurrently
urls = [url] * num_concurrent_requests

# Use ThreadPoolExecutor to parallelize the requests
with concurrent.futures.ThreadPoolExecutor(max_workers=num_concurrent_requests) as executor:
    # Map the make_request function to the list of URLs
    results = list(executor.map(make_request, urls))

# Print the results
for result in results:
    print(result)
