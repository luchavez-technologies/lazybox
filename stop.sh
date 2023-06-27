# decide what program to use
if hash docker-compose 2>/dev/null; then
	docker_compose="docker-compose"
else
	docker_compose="docker compose"
fi

docker_compose="$docker_compose --project-directory dvl"

$docker_compose stop
