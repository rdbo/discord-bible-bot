#!/bin/sh

set -e

mkdir -p cache
docker start discord-bible-bot || docker build -t discord-bible-bot . && docker run -v "$(pwd)/.env:/app/.env" -v "$(pwd)/cache:/app/cache" --name discord-bible-bot --restart on-failure:5 discord-bible-bot
