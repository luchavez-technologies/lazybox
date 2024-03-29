# Create and run a new Lumen app
function lumen_new() {
	local framework="Lumen"
	local framework_version=""
	local php_version
	local vhost
	local app

	app=$(ask_app_name "$framework" "$1")
	vhost="$app"
	framework_version=$(ask_framework_version $framework "$framework_version" "$2")
	echo_php_versions
	php_version=$(ask_php_version "$3")
	ensure_current_php_container "$php_version"

	if [ -n "$framework_version" ]; then
		framework_version=":^$framework_version"
		# check if the version does not have a period
		if echo "$framework_version" | grep -qv "\."; then
			framework_version+=".0"
		fi
	fi

	cd /shared/httpd || stop_function

	echo_ongoing "Now creating your awesome $framework app! 🔥"

	mkdir "$vhost"

	cd "$vhost" || stop_function

	# create project
	execute "composer create-project laravel/lumen$framework_version $app"
	#npm_pkg_add_node_engine "$vhost" "$app" "$4"
	#npm_yarn_install "$vhost" "$app" "$4"

	# symlink and add devilbox config
	symlink "$vhost" "$app"
	php_change "$vhost" "$php_version" 1

	cd "$app" || stop_function

	env=".env"
	# run migrate:fresh --seed if .env exists
	if [ -f $env ]; then
		lumen_replace_env_variables "$app"
		pa migrate --seed 2>/dev/null
	fi

	reload_watcherd_message
	welcome_to_new_app_message "$app"
}

# Clone and run a Lumen app
function lumen_clone() {
	local framework="Lumen"
	local url=""
	local branch="develop"
	local php_version
	local app
	local vhost
	local env
	local env_example

	url=$(ask_git_url "$framework" "$1")
	branch=$(ask_branch_name "$2")
	app=$(ask_app_name "$framework" "$3")
	vhost="$app"
	echo_php_versions
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

	# install dependencies
	composer_install
	#npm_pkg_add_node_engine "$vhost" "$app" "$5"
	#npm_yarn_install "$vhost" "$app" "$5"

	# copy .env.example to .env
	env=".env"
	env_example=".env.example"

	if [ ! -f "$env" ] && [ -f "$env_example" ]; then
		if cp "$env_example" "$env"; then
			lumen_replace_env_variables "$app"
		fi
	fi

	# migrate and seed
	pa migrate --seed 2>/dev/null

	reload_watcherd_message
	welcome_to_new_app_message "$app"
}

# Replace all necessary env variables
function lumen_replace_env_variables() {
	local framework="Lumen"
	local file=".env"
	local name
	local snake_name

	name=$(ask_app_name "$framework" "$1" "$1")

	snake_name=${name//-/_}

	text_replace "^APP_NAME=$framework$" "#APP_NAME=$framework\nAPP_NAME=\"$app\"" "$file"
	text_replace "^APP_URL=http:\/\/localhost$" "#APP_URL=http:\/\/localhost\nAPP_URL=https:\/\/$app.$TLD_SUFFIX" "$file"

	###
	### DATABASE VARIABLES
	###

	# This is for DB_HOST
	text_replace "^DB_HOST=127.0.0.1$" "#DB_HOST=127.0.0.1\nDB_HOST=mysql" "$file"

	# This is for DB_PORT
	text_replace "^DB_PORT=3306$" "#DB_PORT=3306\nDB_PORT=\"\$\{HOST_PORT_MYSQL\}\"" "$file"

	# This is for DB_USERNAME
	text_replace "^DB_USERNAME=homestead$" "#DB_USERNAME=homestead\nDB_USERNAME=root" "$file"

	# This is for DB_PASSWORD
	text_replace "^DB_PASSWORD=secret$" "#DB_PASSWORD=secret\nDB_PASSWORD=\"\$\{MYSQL_ROOT_PASSWORD\}\"" "$file"

	# This is for DB_DATABASE
	if text_replace "^DB_DATABASE=homestead$" "#DB_DATABASE=homestead\nDB_DATABASE=$snake_name" "$file"; then
		password=$MYSQL_ROOT_PASSWORD
		if [ -z "$password" ]; then
			mysql -u root -h mysql -e "create database $snake_name"
		else
			mysql -u root -h mysql -e "create database $snake_name" -p "$password"
		fi
	fi

	# This is for DB_PASSWORD
	text_replace "^DB_PASSWORD=$" "#DB_PASSWORD=\nDB_PASSWORD=\"\$\{MYSQL_ROOT_PASSWORD\}\"" "$file"

	###
	### REDIS VARIABLES
	###

	# This is for REDIS_HOST
	if text_replace "^REDIS_HOST=127.0.0.1$" "#REDIS_HOST=127.0.0.1\nREDIS_HOST=redis" "$file"; then
		# This is for REDIS_PORT
		text_replace "^REDIS_PORT=6379$" "#REDIS_PORT=6379\nREDIS_PORT=\"\$\{HOST_PORT_REDIS\}\"" "$file"

		# This is for SESSION_DRIVER
		text_replace "^SESSION_DRIVER=file$" "#SESSION_DRIVER=file\nSESSION_DRIVER=redis" "$file"

		# This is for QUEUE_CONNECTION
		text_replace "^QUEUE_CONNECTION=sync$" "#QUEUE_CONNECTION=sync\nQUEUE_CONNECTION=redis" "$file"

		# This is for CACHE_DRIVER
		text_replace "^CACHE_DRIVER=file$" "#CACHE_DRIVER=file\nCACHE_DRIVER=redis" "$file"
	fi

	###
	### MAILHOG VARIABLES
	###

	# This is for MAIL_HOST
	text_replace "^MAIL_HOST=smtp.mailtrap.io$" "#MAIL_HOST=smtp.mailtrap.io\nMAIL_HOST=mailhog" "$file"

	# This is for MAIL_PORT
	text_replace "^MAIL_PORT=2525$" "#MAIL_PORT=2525\nMAIL_PORT=\"\$\{HOST_PORT_MAILHOG\}\"" "$file"

	###
	### S3 VARIABLES
	###

	# This is for AWS_ACCESS_KEY_ID
	text_replace "^AWS_ACCESS_KEY_ID=$" "#AWS_ACCESS_KEY_ID=\nAWS_ENDPOINT=\"https:\/\/api.minio.$TLD_SUFFIX\"\nAWS_ACCESS_KEY_ID=\"\$\{MINIO_USERNAME\}\"" "$file"

	# This is for AWS_SECRET_ACCESS_KEY
	text_replace "^AWS_SECRET_ACCESS_KEY=$" "#AWS_SECRET_ACCESS_KEY=\nAWS_SECRET_ACCESS_KEY=\"\$\{MINIO_PASSWORD\}\"" "$file"

	# This is for AWS_BUCKET
	if text_replace "^AWS_BUCKET=$" "#AWS_BUCKET=\nAWS_BUCKET=$app" "$file"; then
		text_replace "^AWS_USE_PATH_STYLE_ENDPOINT=false$" "#AWS_USE_PATH_STYLE_ENDPOINT=false\nAWS_USE_PATH_STYLE_ENDPOINT=true" "$file"
		text_replace "^FILESYSTEM_DRIVER=local$" "#FILESYSTEM_DRIVER=local\nFILESYSTEM_DRIVER=s3" "$file"
		text_replace "^FILESYSTEM_DISK=local$" "#FILESYSTEM_DISK=local\nFILESYSTEM_DISK=s3" "$file"
	fi
}
