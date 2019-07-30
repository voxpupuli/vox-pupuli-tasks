#!/bin/bash
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker build -t voxpupuli/vox-pupli-tasks:latest .
docker push voxpupuli/vox-pupuli-tasks:latest
