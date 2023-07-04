alias yii='php yii'

# Create and run a new Yii app
function yii_new() {
	local framework="Yii"
	local php_version
	local vhost

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"

	php_version=$(ask_php_version "$3")

	ensure_current_php_container "$php_version"

	cd /shared/httpd || stop_function

	echo_ongoing "Now creating your awesome $framework app! 🔥"

	mkdir "$vhost"

	cd "$vhost" || stop_function

	# create project
	composer create-project yiisoft/yii2-app-basic "$app"

	# symlink and add devilbox config
	symlink "$vhost" "$app"
	php_change "$vhost" "$php_version" 1

	cd "$app" || stop_function

	yii_replace_env_variables "$app"
	yii migrate 2>/dev/null

	reload_watcherd_message
	welcome_to_new_app_message "$app"
}

# Clone and run a Yii app
function yii_clone() {
	local framework="Yii"
	local url=""
	local branch="develop"
	local php_version
	local app
	local vhost

	url=$(ask_git_url "$framework" "$1")
	branch=$(ask_branch_name "$2")
	app=$(ask_app_name "$framework" "$3")
	vhost="$app"
	php_version=$(ask_php_version "$4")
	ensure_current_php_container "$php_version"

	cd /shared/httpd || stop_function

	echo_ongoing "Now cloning your awesome $framework app! 🔥"

	mkdir "$vhost"

	cd "$vhost" || stop_function

	execute "git clone $url $app -b $branch 2>/dev/null"

	# symlink and add devilbox config
	symlink "$vhost" "$app"
	php_change "$vhost" "$php_version" 1

	cd "$app" || stop_function

	yii_replace_env_variables "$app"
	yii migrate

	# install dependencies
	composer_install
	npm_pkg_add_node_engine "$vhost" "$app"
	npm_yarn_install "$vhost" "$app"

	reload_watcherd_message
	welcome_to_new_app_message "$app"
}

# Replace all necessary env variables
function yii_replace_env_variables() {
	local framework="Yii"
	local name
	local snake_name

	name=$(ask_app_name "$framework" "$1" "$1")

	snake_name=${name//-/_}

	###
	### DATABASE VARIABLES
	###
	local file="config/db.php"

	# This is for DB_PASSWORD
	password=$MYSQL_ROOT_PASSWORD
	text_replace "'password' => ''" "'password' => '$password'" "$file"

	port=$HOST_PORT_MYSQL

	if text_replace "mysql:host=localhost;dbname=yii2basic" "mysql:host=mysql;dbname=$snake_name;port=$port" "$file"; then
		if [ -z "$password" ]; then
			mysql -u root -h mysql -e "create database $snake_name"
		else
			mysql -u root -h mysql -e "create database $snake_name" -p "$password"
		fi

		return 0
	fi

	return 1
}
