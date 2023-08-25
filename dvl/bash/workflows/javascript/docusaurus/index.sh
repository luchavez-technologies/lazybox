# Create and run a new Docusaurus app
function docusaurus_new() {
	local framework="Docusaurus"
	local framework_version="latest"
	local app
	local vhost
	local port=3000
	local node_version
	local template

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")
	template=$(ask_docusaurus_template "$3")

	if [ $# -ge 3 ]; then
		shift 3
	else
		shift $#
	fi

	cd /shared/httpd || stop_function

	mkdir "$vhost"
	cd "$vhost" || stop_function
	port_change "$vhost" "$port"

	echo_ongoing "Now creating your awesome $framework app! 🔥" bold green

	# Reference: https://docusaurus.io/docs/installation
	execute "npx create-docusaurus@$framework_version $app $template --skip-install $* 2>/dev/null"

	cd "$app" || stop_function

	npm_yarn "$vhost" "$app" "$node_version" cache clean --force
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host 0.0.0.0 --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# Clone and run a Docusaurus app
function docusaurus_clone() {
	local framework="Docusaurus"
	local url=""
	local port=8000
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

	npm_yarn "$vhost" "$app" "$node_version" cache clean --force
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host 0.0.0.0 --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# Publish AWS CodeBuild configs
function docusaurus_aws_codebuild_publish() {
	local framework="Docusaurus"

	node_aws_codebuild_publish "$framework" "$@"
}

# Ask for Docusaurus template
function ask_docusaurus_template() {
	local template
	local default_template="classic"

	template=${1:-$(ask "Please enter Docusaurus $(style "template" underline bold) to use (default: $(style " $default_template " bg-white bold))")}

	if [ -z "$template" ]; then
		template="$default_template"
	fi

	echo "$template"
	return 0
}
