#!/bin/sh

set -e

mkdir -p cache
docker build -t discord-bible-bot .
docker run -v cache:/app/cache --name discord-bible-bot --restart on-failure:5 discord-bible-bot
