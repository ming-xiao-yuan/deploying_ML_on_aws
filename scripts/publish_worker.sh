#!/bin/bash
# Build the Docker image
docker build -f ../worker/Dockerfile -t worker ../worker

# # Tag the Docker image
#docker tag worker mingxiaoyuan/worker:latest
docker tag worker ikrash3d/worker:latest

# # Push the Docker image to the repository
# docker push mingxiaoyuan/worker:latest
docker push ikrash3d/worker:latest