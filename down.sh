#!/bin/sh

# WARNING: Be careful since all volumes will be removed.

# decide what program to use
if hash docker-compose 2>/dev/null; then
	prepend="docker-compose"
else
	prepend="docker compose"
fi

$prepend down -v
