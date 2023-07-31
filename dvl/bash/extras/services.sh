# CURL request to a service
function curl_service() {
	local container

	container=$(ask_container_name "$1")

	curl --write-out "%{http_code}\n" --silent --output /dev/null "$container"
}

# Loop until CURL is successful
function echo_curl_service() {
    local container
    local seconds

	container=$(ask_container_name "$1")
	seconds=${2:-5}
	elapsed=0

	while true; do
	    response=$(curl_service "$container")

	    if [ "$response" -ge 200 ] && [ "$response" -le 300 ]; then
	        echo_success "$container is $(style "now accessible" bold)"
	        break
	    else
	    	sleep "$seconds"
	    	((elapsed=elapsed+seconds))
	    	echo_ongoing "$container is $(style "not yet accessible" bold) ($elapsed s)"
	    fi
	done
}

# Loop until CURL is successful
function echo_curl_httpd() {
    local container="httpd"
    local seconds

	seconds=${1:-5}

	echo_info "The $(style " httpd " bold bg-white) service might take some time to recover."
	echo_message "In the meantime, please rest or do some stretching."
	echo_curl_service "$container" "$seconds"
	echo_success "The Devilbox UI is now ready: https://localhost"
}

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

# List all addon services
function services() {
    echo mailhog memcd minio mongo mysql ngrok pgsql redis soketi
}

# Sync services' vhosts based on their availability
function sync_services_vhosts() {
	local services

	read -a services<<<"$(services)"

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
