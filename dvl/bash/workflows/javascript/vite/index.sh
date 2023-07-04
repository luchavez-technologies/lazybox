# Create and run a new Vite app
function vite_new() {
	local framework="ViteJS"
	local framework_version="latest"
	local port=5173
	local vhost

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"
	framework_version=$(ask_framework_version "$framework" "$framework_version" "$2")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$3")

	cd /shared/httpd || stop_function

	mkdir "$vhost"
	cd "$vhost" || stop_function
	port_change "$vhost" "$port" 1

	echo_ongoing "Now creating your awesome $framework app! 🔥" bold green

	npx create-vite@"$framework_version" "$app" 2>/dev/null

	cd "$app" || stop_function

	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# Clone and run a Vite app
function vite_clone() {
	local framework="ViteJS"
	local url=""
	local port=5173
	local branch="develop"
	local app
	local vhost

	url=$(ask_git_url "$framework" "$1")
	branch=$(ask_branch_name "$2")
	app=$(ask_app_name $framework "$3")
	vhost="$app"
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$4")

	cd /shared/httpd || stop_function

	echo_ongoing "Now creating your awesome $framework app! 🔥" bold green
	mkdir "$app"

	cd "$app" || stop_function

	execute "git clone $url $app -b $branch 2>/dev/null"
	port_change "$vhost" "$port" 1

	cd "$app" || stop_function

	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}
