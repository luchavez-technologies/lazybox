# Stop currently executing function
function stop_function() {
	kill -INT $$
	return 1
}

# Ask an input
function ask() {
	local prompt

	if [ -n "$1" ]; then
		prompt=$1
	else
		read -rp "$(echo_input "Please enter your $(style "prompt" underline bold)")" prompt

		if [ -z "$prompt" ]; then
			stop_function
		fi
	fi

	read -rp "$(echo_input "$prompt")" output

	echo "$output"
	return 0
}

# Ask for framework name
function ask_framework_name() {
	local framework

	framework=${1:-$(ask "Please enter $(style "framework name" underline bold)")}
	echo "${framework:-$(ask_framework_name)}"
	return 0
}

# Ask for framework version
function ask_framework_version() {
	local framework
	local default_version
	local default_version_display="latest"
	local framework_version

	framework=$(ask_framework_name "$1")

	if [ -n "$2" ]; then
		default_version=$2
		default_version_display=$2
	fi

	framework_version=${3:-$(ask "Please enter $framework $(style "version" underline bold) (default: $(style " $default_version_display " bg-white bold))")}

	echo "${framework_version:-$default_version}"
	return 0
}

# Ask for app name
function ask_app_name() {
	local framework
	local default_name
	local name

	framework=$(ask_framework_name "$1")

	# vhost name
	default_name=${3:-$(pwd | sed -e 's/\/shared\/httpd\///' -e 's/\/.*//')}
	default_name=${default_name:-"app-$RANDOM"}

	# app name
	name=${2:-$(pwd | sed -e 's/\/shared\/httpd\/[^/]*\///' -e 's/\/.*//')}
	name=${name:-$(ask "Please enter $framework $(style "app name" underline bold) (default: $(style " $default_name " bg-white bold))")}
	name=${name:-$default_name}
	name=$(clean_name "$name")

	# If "$3" is not empty, it means that it's a vhost name. An error should be thrown if the vhost directory does not exist.
	# If "$3" is empty, it means that an app will be created. An error should be thrown if the vhost directory exists.
	if [ -n "$3" ] && [ ! -d "/shared/httpd/$3/$name" ]; then
		echo_error "The app name ($(style $name underline bold)) does not exist!"
		ask_app_name "$1" "" "$3"
	elif [ -z "$3" ] && [ -d "/shared/httpd/$name" ]; then
		echo_error "The vhost name ($(style $name underline bold)) is already taken!"
		ask_app_name "$1" "" "$3"
	else
		echo "$name"
		return 0
	fi

	return 1
}

# Ask for VHost name
function ask_vhost_name() {
	local vhost

	vhost=${1:-$(pwd | sed -e 's/\/shared\/httpd\///' -e 's/\/.*//')}
	vhost=${vhost:-$(ask "Please enter $(style "vhost name" underline bold)")}

	vhost=$(clean_name "$vhost")

	if [ -z "$vhost" ] || [ ! -d "/shared/httpd/$vhost" ]; then
		ask_vhost_name ""
	else
		echo "$vhost"
		return 0
	fi
}

# Ask for Git URL
function ask_git_url() {
	local framework
	local url

	framework=$(ask_framework_name "$1")

	url=${2:-$(ask "Please enter $(style "Git URL" underline bold) of your $framework app")}

	echo "${url:-$(ask_git_url "")}"
	return 0
}

# Ask for Git branch name
function ask_branch_name() {
	local branch
	local default_branch="develop"

	branch=${1:-$(ask "Please enter $(style "branch name" underline bold) to checkout at (default: $(style " $default_branch " bg-white bold))")}

	echo "${branch:-$default_branch}"
	return 0
}

# Ask for PHP version
function ask_php_version() {
	local version
	local current

	current=$(php_version)

	if [ -n "$1" ]; then
		version=$1
	else
		echo_php_versions
		version=$(ask "Please enter $(style "PHP container" underline bold) to run the app on (default: $(style " $current " bg-white bold))")
	fi

	if [ -z "$version" ] || ! is_php_container_valid "$version"; then
		version="$current"
	fi

	echo "$version"
	return 0
}

# Ask for Node version
function ask_node_version() {
	local version
	local current

	current=$(node_version)

	version=${1:-$(ask "Please enter $(style "NodeJS version" underline bold) (default: $(style " $current " bg-white bold))")}
	version=${version:-$current}

	if [ "$version" != "$current" ]; then
		nvm install "$version" &>/dev/null
	fi

	node_version
}

# Ask for confirmation
function ask_confirmation() {
	local prompt
	local choice

	prompt=${1:-$(ask "Please enter your $(style "prompt" underline bold)")}

	if [ -z "$prompt" ]; then
		echo_error "Your prompt is empty."
		ask_confirmation ""
	else
		read -rp "$(echo_input "$prompt (y/N)")" -n 1 choice
		if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
			return 0
		else
			return 1
		fi
	fi
}

# Ask for container name
function ask_container_name() {
	local container

	container=${1:-$(ask "Please enter $(style "container name" underline bold)")}

	echo "${container:-$(ask_container_name "")}"
	return 0
}
