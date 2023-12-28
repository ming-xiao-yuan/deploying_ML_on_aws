# ML Model Deployment on AWS

## Overview
This project involves deploying a web application on AWS using Docker containers. The application is a simple Flask app that runs inference on a machine learning model.

## Objectives
- Gain hands-on experience running containers on AWS.
- Understand and use Docker for containerization.
- Deploy and run ML model inference in the cloud.
- Utilize code from the first assignment to set up AWS instances.

## Prerequisites
- AWS Account
- Docker installed on Ubuntu instances
- Basic knowledge of Flask and Docker Compose

## Setup and Installation
1. **Install Docker on Ubuntu**: Follow the instructions [here](https://docs.docker.com/engine/install/ubuntu/) using the "Install using the Apt repository" section.
2. **Use Docker Compose**: Build your own Docker container following the instructions in the [Docker Compose overview](https://docs.docker.com/compose/).

## Deployment Architecture
- One M4.large instance as the orchestrator.
- Four M4.large instances as workers, each running two containers.

## Running the Application
1. **Setting Up the Orchestrator**: Run a Flask application on the orchestrator that manages requests and worker instances.
2. **Deploying on Workers**: Each worker runs a Flask application that performs ML model inference and returns JSON responses.

## Experiment and Analysis
- Ensure proper request handling and queuing by the orchestrator.
- Analyze the performance of your deployed containers and Flask applications.

## Reporting
- Compile a detailed report using the LATEX format, including experiments, deployment strategies, and findings.

## Acknowledgements
Thanks to Amazon Web Services for their support through AWS Educate grants.

## References
1. [Docker Installation on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
2. [Docker Compose Overview](https://docs.docker.com/compose/)
3. [Hugging Face Transformers](https://huggingface.co/docs/transformers/model_doc/distilbert)

