# This will change the port where the node app will be expected to run on
function port_change() {
	local php_version
	local vhost
	local port

	vhost=$(ask_vhost_name "$1")
	port=$(ask_port "$2")
	echo_php_versions
	php_version=$(ask_php_version "$3")

	cd "/shared/httpd/$vhost" || stop_function

	mkdir .devilbox 2>/dev/null

	# For backend.cfg
	touch .devilbox/backend.cfg 2>/dev/null
	echo "conf:rproxy:http:$php_version:$port" >.devilbox/backend.cfg

	# For nginx.yml (or apache.yml)
	cp_frontend_web_server_yml "$vhost" "$php_version" "$port"

	reload_watcherd_message
}

# Get the current node version
function node_version() {
	local version

	version=$(node --version)

	echo "${version#v}"
}

# Execute npm or yarn commands
function npm_yarn() {
	local vhost
	local app
	local command

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ $# -ge 2 ]; then
		shift 2
	fi

	command=$(echo_npm_yarn "$vhost" "$app" "$@")

	if [ -n "$command" ]; then
		echo_ongoing "$command"
		eval "$command"
	fi
}

# Echo npm or yarn commands
function echo_npm_yarn() {
	local vhost
	local app

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	path="/shared/httpd/$vhost/$app"

	if [ $# -ge 2 ]; then
		shift 2
	fi

	prepend=""
	cwd=""
	if [ -f "$path/yarn.lock" ]; then
		prepend=yarn
		cwd="cwd"
	elif [ -f "$path/package-lock.json" ] || [ -f "$path/package.json" ]; then
		prepend=npm
		cwd="prefix"
	fi

	if [ -n "$prepend" ]; then
		echo "$prepend --$cwd $path $*"
		return 0
	fi

	echo ""
	return 1
}

# Install NPM dependencies
function npm_yarn_install() {
	local vhost
	local app

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	if [ $# -ge 2 ]; then
		shift 2
	fi

	if [ ! -d node_modules ]; then
		npm_yarn "$vhost" "$app" install "$@"
	else
		echo_error "Dependencies are already installed."
	fi
}

# Install NPM dependencies for production
function npm_yarn_install_production() {
	local vhost
	local app

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")

	npm_yarn_install "$vhost" "$app" --production
}

# Execute npm or yarn commands
function npm_yarn_run() {
	local vhost
	local app

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "JS" "$2" "$vhost")
	path="/shared/httpd/$vhost/$app"

	if [ $# -ge 2 ]; then
		shift 2
	fi

	if [ -d "$path/node_modules" ]; then
		npm_yarn "$vhost" "$app" run "$@"
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
		echo_warning "Skipping since the $(style " $key " bg-white bold) is already set: $value"
		return 1
	fi

	version=$(ask_node_version "$3")
	npm_pkg_set "$vhost" "$app" "$key" ">=$version"
}

# Add a "lazybox" script to package.json
function npm_pkg_add_lazybox() {
	local start_scripts=("dev" "develop" "development" "start")
	local vhost
	local app
	local args
	local value
	local key="lazybox"

	vhost=$(ask_vhost_name "$2")
	app=$(ask_app_name "JS" "$3" "$vhost")

	if [ -n "$4" ]; then
		args="$4"
	else
		args=$(ask "Enter script arguments")
	fi

	# Check if lazybox script already exists
	value=$(npm_pkg_get_script "$vhost" "$app" "$key")

	if [ -n "$value" ]; then
		echo_warning "Skipping since the $(style " $key " bg-white bold) script is already set: $value"
		return 1
	fi

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

	# Create the start.sh script
	if [ -n "$value" ]; then
		command=$(echo_npm_yarn "$vhost" "$app" run $key)
		setup_start_script "$vhost" "$command"
		return 0
	fi

	return 1
}

# Set devilbox as the owner of /opt/nvm directory
function own_nvm() {
	own_directory /opt/nvm
}
