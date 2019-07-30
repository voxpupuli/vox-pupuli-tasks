#!/bin/bash
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker build -t voxpupuli/vox-pupuli-tasks:latest -t "voxpupuli/vox-pupuli-tasks:$(git rev-parse --short HEAD)" .
docker push voxpupuli/vox-pupuli-tasks:latest
docker push "voxpupuli/vox-pupuli-tasks:$(git rev-parse --short HEAD)"
