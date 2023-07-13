#!/bin/bash

# To run from shiraz:
# ./flutter_docker.sh
# adb pair <moscato_ip>:2208
# adb connect <moscato_ip>:2209
# flutter run

docker build -t flutter-ai-yu .

docker run \
    -it \
    --rm \
    --net=host \
    --name flutter \
    -v $(pwd):/app \
    flutter-ai-yu \
    bash
