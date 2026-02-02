#!/bin/sh

set -e

mkdir -p cache
docker build -t discord-bible-bot .
docker run -v "$(pwd)/cache:/app/cache" --restart on-failure:5 discord-bible-bot
