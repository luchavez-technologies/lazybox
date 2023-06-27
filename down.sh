source dvl/bash/extras/style.sh
source dvl/bash/extras/ask.sh

choice=$(ask "The volumes will be deleted. Are you sure you want to proceed? (y/n)")
case "$choice" in
y | Y)
	if hash docker-compose 2>/dev/null; then
		docker_compose="docker-compose"
	else
		docker_compose="docker compose"
	fi

	# Set docker-compose working directory
	docker_compose="$docker_compose --project-directory dvl"

	$docker_compose down -v
	;;
n | N)
	echo "Execution cancelled."
	;;
*)
	echo "Invalid choice."
	;;
esac
