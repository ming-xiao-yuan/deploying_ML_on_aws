import os
from flask import Flask, request, jsonify
import threading
import time
import json
import boto3
import json


app = Flask(__name__)
lock = threading.Lock()
request_queue = []


def send_requests_to_container(container_id, container_info, incoming_request_data):
    print(f"Sending request to {container_id} with data:{incoming_request_data}...")
    # TODO: Put the code to call your instance here
    # this should get the ip of the instance, alongside the port and send the requiest to it
    print(f"Received response from {container_id}.")


def update_container_status(container_id, status):
    with lock:
        with open("test.json", "r") as f:
            data = json.load(f)
        data[container_id]["status"] = status
        with open("test.json", "w") as f:
            json.dump(data, f)


def process_request(incoming_request_data):
    with lock:
        with open("test.json", "r") as f:
            data = json.load(f)

    free_container = None
    for container_id, container_info in data.items():
        if container_info["status"] == "free":
            free_container = container_id
            break
    if free_container:
        update_container_status(free_container, "busy")
        send_requests_to_container(
            free_container, data[free_container], incoming_request_data
        )
        update_container_status(free_container, "free")
    else:
        request_queue.append(incoming_request_data)


@app.route("/new_request", methods=["POST"])
def new_request():
    populate_ip_addresses()
    incoming_request_data = request.json
    threading.Thread(target=process_request, args=(incoming_request_data,)).start()
    return jsonify({"message": "Request received and processing started."})


@app.route("/dummy", methods=["GET"])
def dummy():
    return "<h1>Hello Dummy, I am instance !</h1>"


def populate_ip_addresses():
    AWS_ACCESS_KEY = os.environ.get("AWS_ACCESS_KEY")
    AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")
    AWS_SESSION_TOKEN = os.environ.get("AWS_SESSION_TOKEN")

    # Initialize a boto3 EC2 client
    ec2_client = boto3.client(
        "ec2",
        region_name="us-east-1",
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        aws_session_token=AWS_SESSION_TOKEN,
    )

    # Fetch all EC2 instances with a specific tag, e.g., "Worker"
    response = ec2_client.describe_instances(
        Filters=[{"Name": "tag:Name", "Values": ["Worker-*"]}]
    )

    # A dictionary to hold the mapping of instance ID to public IP
    worker_ips = []

    # Parse the response to collect public IPs of worker instances
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            # Only consider instances that are running and have a public IP
            if instance["State"]["Name"] == "running" and "PublicIpAddress" in instance:
                worker_ips.append(instance["PublicIpAddress"])

    print(worker_ips)

    # Now, read the test.json file
    with open("test.json", "r") as file:
        data = json.load(file)

    # Iterate over the containers and assign IPs from the worker_ips list
    for index, container_key in enumerate(data):
        worker_index = index // 2  # Assuming 2 containers per worker
        port_offset = index % 2  # Alternates between 0 and 1 for ports 5000 and 5001
        if worker_index < len(worker_ips):  # Check to avoid index out of range
            data[container_key]["ip"] = worker_ips[worker_index]
            data[container_key]["port"] = str(
                5000 + port_offset
            )  # Alternate between ports 5000 and 5001

    # Write the updated data back to the test.json file
    with open("test.json", "w") as file:
        json.dump(data, file, indent=4)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
