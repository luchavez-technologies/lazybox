# Copy nginx or apache yml to vhost (rproxy)
function cp_frontend_web_server_yml() {
	local vhost
	local php_version
	local port
	local vhost_directory
	local yml_example
	local yml
	local key
	local php_version_port

	vhost=$(ask_vhost_name "$1")
	echo_php_versions
	php_version=$(ask_php_version "$2")
	port=$(ask_port "$3")

	# Check if vhost and app exists
	vhost_directory="/shared/httpd/$vhost"

	# Make sure the .devilbox folder exists
	mkdir "$vhost_directory/.devilbox" 2>/dev/null

	yml_example=$(get_vhost_gen_yml_name rproxy)
	yml=${yml_example%%-example*}

	# Copy the vhost-gen yml to .devilbox
	if [ ! -f "$vhost_directory/.devilbox/$yml" ] && cp "/cfg/vhost-gen/$yml_example" "$vhost_directory/.devilbox/$yml"; then
		echo_success "Successfully copied $(style " $yml_example " bg-white bold) to $(style " $vhost_directory/.devilbox/$yml " bg-white bold)."
		text_replace "php:8000" "$php_version:$port" "$vhost_directory/.devilbox/$yml"
		return 0
	fi

	# Replace if the file already exists
	key="proxy_pass http://"
	php_version_port=$(grep "$key" "$vhost_directory/.devilbox/$yml" | awk -F "$key" '{print $2}')

	if [ -n "$php_version_port" ]; then
		text_replace "$php_version_port" "$php_version:$port;" "$vhost_directory/.devilbox/$yml"
		return 0
	fi

	return 1
}

# Copy nginx or apache yml to vhost (vhost)
function cp_backend_web_server_yml() {
	local vhost
	local web_root
	local file
	local vhost_directory
	local yml_example
	local yml

	vhost=$(ask_vhost_name "$1")
	ask_app_name "PHP" "$vhost" "$2"

	web_root=${3:-$(ask "Please enter $(style "web root" underline bold) directory")}

	if [ -z "$web_root" ]; then
		web_root="public"
	fi

	file=${4:-$(ask "Please enter $(style "entry point" underline bold) file")}

	if [ -z "$file" ]; then
		file="index.php"
	fi

	# Check if vhost and app exists
	vhost_directory="/shared/httpd/$vhost"

	if [ "$file" != "index.php" ]; then
		# Make sure the .devilbox folder exists
		mkdir "$vhost_directory/.devilbox" 2>/dev/null

		yml_example=$(get_vhost_gen_yml_name vhost)
		yml=${yml_example%%-example*}

		if cp "/cfg/vhost-gen/$yml_example" "$vhost_directory/.devilbox/$yml"; then
			echo_success "Successfully copied $(style " $yml_example " bg-white bold) to $(style " $vhost_directory/.devilbox/$yml " bg-white bold)."
			text_replace "__INDEX__;" "$file __INDEX__;" "$vhost_directory/.devilbox/$yml"
			text_replace "index.php" "$file" "$vhost_directory/.devilbox/$yml"
		else
			echo_error "Failed to copy $(style " $yml_example " bg-white bold) to $(style " $vhost_directory/.devilbox/$yml " bg-white bold)."
		fi
	fi
}

# Get nginx/apache example yml name
function get_vhost_gen_yml_name() {
	if [ -n "$1" ]; then
		type=$1
	else
		types=("vhost" "rproxy")
		while true; do
			echo "Here are the vhost types: $(style " ${types[*]} " bg-white bold)"
			type=$(ask "Please enter $(style "vhost type" underline bold)")

			if [ -n "$type" ] && printf '%s\n' "${types[@]}" | grep -xq "$type"; then
				break
			fi

			echo_error "Invalid vhost type!"
		done
	fi

	declare -A ymls

	ymls["apache-2.2"]="apache22.yml-example"
	ymls["apache-2.4"]="apache24.yml-example"
	ymls["nginx-stable"]="nginx.yml-example"
	ymls["nginx-mainline"]="nginx.yml-example"

	echo "${ymls[$HTTPD_SERVER]}-$type"
}
