# Create and run a new AstroJS app
# Templates: https://github.com/withastro/astro/tree/latest/examples
function astro_new() {
	local framework="AstroJS"
	local framework_version="latest"
	local template
	local port=3000
	local vhost

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"
	framework_version=$(ask_framework_version "$framework" "$framework_version" "$2")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$3")
	template=$(ask_astro_template "$4")

	if [ $# -ge 3 ]; then
		shift 4
	else
		shift $#
	fi

	if [ -n $template ]; then
	    template="-- --template $template"
	fi

	cd /shared/httpd || stop_function

	mkdir "$vhost"
	cd "$vhost" || stop_function
	port_change "$vhost" "$port"

	echo_ongoing "Now creating your awesome $framework app! 🔥" bold green

	execute "npx create-astro@$framework_version $app --no-install --no-git $template $* 2>/dev/null"

	cd "$app" || stop_function

	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# Clone and run a AstroJS app
function astro_clone() {
	local framework="AstroJS"
	local url=""
	local port=3000
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
	port_change "$vhost" "$port"

	cd "$app" || stop_function

	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# Ask for Astro template
function ask_astro_template() {
	local template

	template=${1:-$(ask "Please enter Astro $(style "template" underline bold) to use")}

	echo "$template"
	return 0
}
