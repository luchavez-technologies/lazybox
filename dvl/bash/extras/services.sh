# Ping a service/container
function ping_service() {
	local container

	container=$(ask_container_name "$1")

	ping -c 1 -w 1 "$container"
}

# Test if a service can be pinged
function test_service() {
	local container

	container=$(ask_container_name "$1")

	ping_service "$container" &>/dev/null && return 0 || return 1
}

# Display service status
function echo_test_service() {
	local container

	container=$(ask_container_name "$1")

	if test_service "$container"; then
	    echo_success "$container is $(style "online" bold)"
	else
		echo_error "$container is $(style "offline" bold)"
	fi
}

# Create symlink to services based on its availability
function symlink_services() {
	local services=( "mailhog" "memcd" "minio" "mongo" "mysql" "ngrok" "pgsql" "redis" "soketi" )

	cd /shared/httpd || stop_function

	for service in "${services[@]}"; do
		# Remove the service first
		rm -rf ./*"$service" &>/dev/null
		# Check if the service can be pinged
		if test_service "$service"; then
			cp -rf /services/*"$service" . &>/dev/null
		fi
    done
}
