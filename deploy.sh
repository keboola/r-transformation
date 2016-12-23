#!/bin/bash

docker login -e="." -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io
docker tag keboola/r-transformation quay.io/keboola/r-transformation:$TRAVIS_TAG
docker tag keboola/r-transformation quay.io/keboola/r-transformation:latest
docker images
docker push quay.io/keboola/r-transformation:$TRAVIS_TAG
docker push quay.io/keboola/r-transformation:latest
