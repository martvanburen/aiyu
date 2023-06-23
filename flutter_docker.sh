#!/bin/bash

docker build -t flutter-ai-yu .

docker run \
    -it \
    --rm \
    --net=host \
    --name flutter \
    -v $(pwd):/app \
    flutter-ai-yu \
    bash
