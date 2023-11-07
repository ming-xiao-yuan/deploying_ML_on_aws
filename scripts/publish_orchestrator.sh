#!/bin/bash
# Build the Docker image
docker build -f ../orchestrator/Dockerfile -t orchestrator ../orchestrator

# # Tag the Docker image
# docker tag orchestrator mingxiaoyuan/orchestrator:latest
docker tag orchestrator ikrash3d/orchestrator:latest

# # Push the Docker image to the repository
# docker push mingxiaoyuan/orchestrator:latest
docker push ikrash3d/orchestrator:latest
