docker run \
    -it \
    --rm \
    --name flutter \
    -v $(pwd):/app \
    -w /app \
    instrumentisto/flutter \
    flutter $@
