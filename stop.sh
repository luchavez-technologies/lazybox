#!/bin/sh

# decide what program to use
if hash docker-compose 2>/dev/null; then
	prepend="docker-compose"
else
	prepend="docker compose"
fi

$prepend stop
