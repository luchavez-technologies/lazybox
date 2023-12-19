# This will change the port where the node app will be expected to run on
function port_change() {
	local php_version
	local vhost
	local port
	local show_message

	vhost=$(ask_vhost_name "$1")
	port=$(ask_port "$2")
	echo_php_versions
	php_version=$(ask_php_version "$3")
	show_message=${4:-0}

	cd "/shared/httpd/$vhost" || stop_function

	mkdir .devilbox 2>/dev/null

	# For backend.cfg
	touch .devilbox/backend.cfg 2>/dev/null
	echo "conf:rproxy:http:$php_version:$port" >.devilbox/backend.cfg

	# For nginx.yml (or apache.yml)
	cp_frontend_web_server_yml "$vhost" "$php_version" "$port"

	if [ $show_message ]; then
		reload_watcherd_message
	fi
}

# Get the current node version
function node_version() {
	local version

	version=$(node --version)

	echo "${version#v}"
	return 0
}

# Echo npm or yarn commands
function echo_npm_yarn() {
	local vhost
	local app
	local node_version

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	node_version=$(npm_pkg_get_node_engine "$vhost" "$app")

	if [ -z "$node_version" ] || ! nvm install "$node_version" &>/dev/null; then
		node_version=$(ask_node_version "$3")
	fi

	path="/shared/httpd/$vhost/$app"

	if [ $# -ge 3 ]; then
		shift 3
	else
		shift $#
	fi

	manager=""
	cwd=""
	if [ -f "$path/yarn.lock" ]; then
		manager=yarn
		cwd="cwd"
	elif [ -f "$path/package-lock.json" ] || [ -f "$path/package.json" ]; then
		manager=npm
		cwd="prefix"
	fi

	if [ -n "$manager" ]; then
		echo "nvm install $node_version; nvm exec $node_version $manager --$cwd $path $*"
		return 0
	fi

	echo ""
	return 1
}

# Execute npm or yarn commands
function npm_yarn() {
	local vhost
	local app
	local node_version
	local command

	vhost=$1
	app=$2
	node_version=$3

	if [ $# -ge 3 ]; then
		shift 3
	else
		shift $#
	fi

	command=$(echo_npm_yarn "$vhost" "$app" "$node_version" "$@")

	if [ -n "$command" ]; then
		echo_ongoing "$command"
		eval "$command"
	fi
}

# Install NPM dependencies
function npm_yarn_install() {
	local vhost
	local app
	local node_version

	vhost=$1
	app=$2
	node_version=$3

	if [ $# -ge 3 ]; then
		shift 3
	else
		shift $#
	fi

	if [ ! -d node_modules ]; then
		npm_yarn "$vhost" "$app" "$node_version" install "$@"
	else
		echo_error "Dependencies are already installed."
	fi
}

# Install NPM dependencies for production
function npm_yarn_install_production() {
	local vhost
	local app
	local node_version

	vhost=$1
	app=$2
	node_version=$3

	npm_yarn_install "$vhost" "$app" "$node_version" --production
}

# Execute npm or yarn commands
function npm_yarn_run() {
	local vhost
	local app
	local node_version
	local path

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	node_version=$3

	path="/shared/httpd/$vhost/$app"

	if [ $# -ge 3 ]; then
		shift 3
	else
		shift $#
	fi

	if [ -d "$path/node_modules" ]; then
		npm_yarn "$vhost" "$app" "$node_version" run "$@"
	else
		echo_error "Dependencies are not yet installed."
	fi
}

# Get value from package.json
function npm_pkg_get() {
	local vhost
	local app
	local key

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ -n "$3" ]; then
		key="$3"
	else
		key=$(ask "Enter search key")
	fi

	value="$(npm pkg get "$key" --prefix "/shared/httpd/$vhost/$app")"

	# Return empty string if value is equal to "{}"
	if [ "$value" != "{}" ]; then
		echo "$value" && return 0
	else
		echo "" && return 1
	fi
}

# Set value on package.json
function npm_pkg_set() {
	local vhost
	local app
	local key
	local value

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ -n "$3" ]; then
		key="$3"
	else
		key=$(ask "Enter key")
	fi

	if [ -n "$4" ]; then
		value="$4"
	else
		value=$(ask "Enter value")
	fi

	execute "npm pkg set '$key=$value' --prefix /shared/httpd/$vhost/$app"
}

# Get value from package.json
function npm_pkg_get_script() {
	local vhost
	local app
	local key

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ -n "$3" ]; then
		key="$3"
	else
		key=$(ask "Enter search key")
	fi

	npm_pkg_get "$vhost" "$app" "scripts.$key" && return 0 || return 1
}

# Set value on package.json
function npm_pkg_set_script() {
	local vhost
	local app
	local key
	local value

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ -n "$3" ]; then
		key="$3"
	else
		key=$(ask "Enter script key")
	fi

	if [ -n "$4" ]; then
		value="$4"
	else
		value=$(ask "Enter script value")
	fi

	npm_pkg_set "$vhost" "$app" "scripts.$key" "$value" && return 0 || return 1
}

# Add a node engine version to package.json
function npm_pkg_add_node_engine() {
	local vhost
	local app
	local version
	local value
	local key="engines.node"

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	value=$(npm_pkg_get "$vhost" "$app" "$key")

	if [ -n "$value" ]; then
		echo_warning "The $(style " $key " bg-white bold) is already set: $value"
		return 1
	fi

	version=$(ask_node_version "$3")
	npm_pkg_set "$vhost" "$app" "$key" ">=$version"
}

# Get node engine version from package.json
function npm_pkg_get_node_engine() {
	local vhost
	local app
	local version
	local key="engines.node"

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	version=$(npm_pkg_get "$vhost" "$app" "$key" | grep -oE '[0-9.]+')

	echo "${version:-$(node_version)}"
}

# Add a "lazybox" script to package.json
function npm_pkg_add_lazybox() {
	local start_scripts=("dev" "develop" "development" "start")
	local vhost
	local app
	local args
	local value
	local key="lazybox"

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	node_version=$(npm_pkg_get_node_engine "$vhost" "$app")
	if [ -z "$node_version" ] || ! nvm install "$node_version" &>/dev/null; then
		node_version=$(ask_node_version "$3")
	fi
	args=${4:-$(ask "Enter script arguments")}

	# Check if lazybox script already exists
	value=$(npm_pkg_get_script "$vhost" "$app" "$key")

	if [ -n "$value" ]; then
		echo_warning "The $(style " $key " bg-white bold) script is already set: $value"
	else
		for script in "${start_scripts[@]}"; do
			# Find and get the script
			value=$(npm_pkg_get_script "$vhost" "$app" "$script" | tr -d '"')
			if [ -n "$value" ]; then
				# Append the args if does not exist
				if ! echo "$value" | grep -q -- "$args$"; then
					value="${value} ${args}"
				fi

				npm_pkg_set_script "$vhost" "$app" "$key" "$value"
				break
			fi
		done
	fi

	# Create the start.sh script
	if [ -n "$value" ]; then
		command=$(echo_npm_yarn "$vhost" "$app" "$node_version" run "$key")
		setup_start_script "$vhost" "source /opt/nvm/nvm.sh; $command"
		return 0
	fi

	return 1
}

# Set devilbox as the owner of /opt/nvm directory
function own_nvm() {
	own_directory /opt/nvm
}
