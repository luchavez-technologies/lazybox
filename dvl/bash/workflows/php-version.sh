# List the available PHP containers
function php_versions() {
	echo php php54 php55 php56 php70 php71 php72 php73 php74 php80 php81 php82
}

# List the available PHP containers
function echo_php_versions() {
	local containers
	local string="Here are the available PHP containers:"

	read -a containers <<<"$(php_versions)"

	for container in "${containers[@]}"; do
		string+=" $(style " $container " bg-white bold)"
	done

	echo_info "$string"
}

# Get the current PHP container name
function php_version() {
	declare -A versions
	versions['172.16.238.10']='php'
	versions['172.16.238.201']='php54'
	versions['172.16.238.202']='php55'
	versions['172.16.238.203']='php56'
	versions['172.16.238.204']='php70'
	versions['172.16.238.205']='php71'
	versions['172.16.238.206']='php72'
	versions['172.16.238.207']='php73'
	versions['172.16.238.208']='php74'
	versions['172.16.238.209']='php80'
	versions['172.16.238.210']='php81'
	versions['172.16.238.211']='php82'

	ip=$(ip_address)
	echo "${versions[$ip]}"
}

# Get the default PHP container name
function php_server() {
	version=$PHP_SERVER
	echo "php${version//./}"
}

# Get current IP address
function ip_address() {
	hostname -I | awk '{print $1}'
}

# Check if the PHP container name input is valid
function is_php_container_valid() {
	local containers

	if [ -z "$1" ]; then
		return 1
	fi

	input=$1

	read -a containers <<<"$(php_versions)"

	for container in "${containers[@]}"; do
		if [ "$input" == "$container" ]; then
			return 0
		fi
	done

	return 1
}

# Check if the PHP container name input matches the current container
function is_php_container_current() {
	if [ -z "$1" ] || ! is_php_container_valid "$1"; then
		return 1
	fi

	current=$(php_version)

	if [ "$1" == "$current" ]; then
		return 0
	fi

	return 1
}
