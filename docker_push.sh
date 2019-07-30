#!/bin/bash
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker build .
docker push "${DOCKER_USERNAME}/vox-pupuli-tasks"
