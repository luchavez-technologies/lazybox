# Set Ngrok Settings
function setup_ngrok() {
	env="/.env"

	current_vhost_variable="NGROK_VHOST="
	current_vhost=$(grep "^$current_vhost_variable*" "$env")

	current_token_variable="NGROK_AUTHTOKEN="
	current_token=$(grep "^$current_token_variable*" "$env")

	vhost="${current_vhost#$current_vhost_variable}"
	token="${current_token#$current_token_variable}"

	v=$(ask_vhost_name $1)

	if [ "$vhost" != "$v" ]; then
		vhost="$v"
		env_text_replace "$current_vhost" "$current_vhost_variable$vhost"
	fi

	if [ -n "$2" ]; then
		t="$2"
	else
		t=$(ask "Please enter $(style "auth token" underline bold) (default: $(style "$token" bold blue))")

		if [ -n "$t" ]; then
			token="$t"
			env_text_replace "$current_token" "$current_token_variable$token"
		fi
	fi

	php_version=$(php_version)

	echo
	echo "✋ If $(style "Ngrok settings" bold blue) has been changed, $(style " exit " bg-white bold) this container first then run $(style "./up.sh $php_version" bold blue)."
}

function setup_start_script() {
	local vhost
	local command

	vhost=$(ask_vhost_name "$1")

	if [ -n "$2" ]; then
		command="$2"
	else
		command=$(ask "Please enter $(style "command" underline bold) to start the app")
	fi

	if [ -z "$command" ]; then
		echo_error "You provided an empty command."
		setup_start_script "$1"
	fi

	cd "/shared/httpd/$vhost" || stop_function

	touch start.sh 2>/dev/null &&
		chmod +x start.sh 2>/dev/null &&
		echo "pm2 delete $vhost 2>/dev/null; pm2 start '$command' --name=$vhost" >start.sh

	echo_success "Successfully created $(style " /shared/httpd/$vhost/start.sh " bg-white bold)."
	echo_message "If you restart all the containers, this start script will automatically run."
	echo_message "To restart, $(style " exit " bg-white bold) this container first, then run $(style " ./stop.sh && ./up.sh " bg-white bold)."
}
