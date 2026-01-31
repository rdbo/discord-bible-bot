#!/bin/sh

set -e

docker build -t discord-bible-bot .
docker run --restart on-failure:5 discord-bible-bot
