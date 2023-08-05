# Create and run a new Vite app
function vite_new() {
	local framework="ViteJS"
	local framework_version="latest"
	local port=5173
	local vhost
	local template

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"
	framework_version=$(ask_framework_version "create-vite" "$framework_version" "$2")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$3")
	echo_vite_templates
	template=$(ask_vite_template "$4")

	cd /shared/httpd || stop_function

	mkdir "$vhost"
	cd "$vhost" || stop_function
	port_change "$vhost" "$port"

	echo_ongoing "Now creating your awesome $framework app! 🔥" bold green

	npx create-vite@"$framework_version" "$app" --template="$template" -y 2>/dev/null

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
	port_change "$vhost" "$port"

	cd "$app" || stop_function

	npm_pkg_add_node_engine "$vhost" "$app" "$node_version"
	npm_yarn_install "$vhost" "$app" "$node_version"
	npm_pkg_add_lazybox "$vhost" "$app" "$node_version" "--host --port $port"
	reload_watcherd_message
	welcome_to_new_app_message "$app"
	vhost_start "$vhost"
}

# List the available ViteJS templates
# Reference: https://vitejs.dev/guide/#scaffolding-your-first-vite-project
function vite_templates() {
	echo vanilla vanilla-ts vue vue-ts react react-ts react-swc react-swc-ts preact preact-ts lit lit-ts svelte svelte-ts solid solid-ts qwik qwik-ts
}

# List the available ViteJS templates
function echo_vite_templates() {
	local templates
	local string="Here are the available ViteJS templates:"

	read -a templates <<<"$(vite_templates)"

	for container in "${templates[@]}"; do
		string+=" $(style " $container " bg-white bold)"
	done

	echo_info "$string"
}

# Check if the ViteJS template name input is valid
function is_vite_template_valid() {
	local templates

	if [ -z "$1" ]; then
		return 1
	fi

	read -a templates <<<"$(vite_templates)"

	for template in "${templates[@]}"; do
		if [ "$1" == "$template" ]; then
			return 0
		fi
	done

	return 1
}

# Ask for ViteJS template
function ask_vite_template() {
	local template

	template=${1:-$(ask "Please enter ViteJS $(style "template" underline bold) to use")}

	if [ -z "$template" ] || ! is_vite_template_valid "$template"; then
		template=$(ask_vite_template "")
	else
		echo "$template"
		return 0
	fi
}

# Template-based Vite New Workflow

# Create and run new Vanilla Vite app
function vite_vanilla_new() {
	local framework="Vite Vanilla"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version vanilla"
}

# Create and run new Vanilla TypeScript Vite app
function vite_vanilla_ts_new() {
	local framework="Vite Vanilla TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version vanilla-ts"
}

# Create and run new Vue Vite app
function vite_vue_new() {
	local framework="Vite Vue"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version vue"
}

# Create and run new Vue TypeScript Vite app
function vite_vue_ts_new() {
	local framework="Vite Vue TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version vue-ts"
}

# Create and run new React Vite app
function vite_react_new() {
	local framework="Vite React"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version react"
}

# Create and run new React TypeScript Vite app
function vite_react_ts_new() {
	local framework="Vite React TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version react-ts"
}

# Create and run new React SWC Vite app
function vite_react_swc_new() {
	local framework="Vite React SWC"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version react-swc"
}

# Create and run new React SWC TypeScript Vite app
function vite_react_swc_ts_new() {
	local framework="Vite React SWC TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version react-swc-ts"
}

# Create and run new Preact Vite app
function vite_preact_new() {
	local framework="Vite Preact"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version preact"
}

# Create and run new Preact TypeScript Vite app
function vite_preact_ts_new() {
	local framework="Vite Preact TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version preact-ts"
}

# Create and run new Lit Vite app
function vite_lit_new() {
	local framework="Vite Lit"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version lit"
}

# Create and run new Lit TypeScript Vite app
function vite_lit_ts_new() {
	local framework="Vite Lit TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version lit-ts"
}

# Create and run new Svelte Vite app
function vite_svelte_new() {
	local framework="Vite Svelte"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version svelte"
}

# Create and run new Svelte TypeScript Vite app
function vite_svelte_ts_new() {
	local framework="Vite Svelte TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version svelte-ts"
}

# Create and run new Solid Vite app
function vite_solid_new() {
	local framework="Vite Solid"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version solid"
}

# Create and run new Solid TypeScript Vite app
function vite_solid_ts_new() {
	local framework="Vite Solid TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version solid-ts"
}

# Create and run new Qwik Vite app
function vite_qwik_new() {
	local framework="Vite Qwik"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version qwik"
}

# Create and run new Qwik TypeScript Vite app
function vite_qwik_ts_new() {
	local framework="Vite Qwik TypeScript"
	local framework_version="latest"
	local app
	local port=5173
	local template

	app=$(ask_app_name "$framework" "$1")
	port=$(port_suggest "$port")
	node_version=$(ask_node_version "$2")

	execute "vite_new $app latest $node_version qwik-ts"
}
