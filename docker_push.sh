#!/bin/bash
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker build -t voxpupuli/vox-pupli-tasks .
docker push "voxpupuli/vox-pupuli-tasks"
