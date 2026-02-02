#!/bin/sh

set -e

docker build -t discord-bible-bot .
docker run --name discord-bible-bot --restart on-failure:5 discord-bible-bot
