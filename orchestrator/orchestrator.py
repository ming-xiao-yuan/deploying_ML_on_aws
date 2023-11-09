import os
from flask import Flask, request, jsonify
import logging
import threading
import time
import json


app = Flask(__name__)
lock = threading.Lock()
request_queue = []


@app.route("/receive_ips_from_workers", methods=["POST"])
def receive_ips():
    # Parse the JSON sent to this endpoint
    worker_ips = request.get_json()  # This assumes the JSON array is sent directly

    # Print the worker_ips to the console
    if worker_ips:
        app.logger.info("Received worker IPs:")
        for ip in worker_ips:
            app.logger.info(ip)
    else:
        app.logger.warning("No worker IPs received")

    # Respond to the client that the request was successful
    return jsonify({"message": "Worker IPs received"}), 200


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
    incoming_request_data = request.json
    threading.Thread(target=process_request, args=(incoming_request_data,)).start()
    return jsonify({"message": "Request received and processing started."})


@app.route("/dummy", methods=["GET"])
def dummy():
    return "<h1>Hello Dummy, I am instance {}!</h1>".format(
        os.environ["INSTANCE_ID_EC2"]
    )


if __name__ == "__main__":
    app.logger.setLevel(logging.INFO)
    app.run(host="0.0.0.0", port=80)
