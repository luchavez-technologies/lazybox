# This will change the PHP container where the vhost will run on
function php_change() {
	local vhost
	local php_version

	vhost=$(ask_vhost_name "$1")
	echo_php_versions
	php_version=$(ask_php_version "$2")

	cd "/shared/httpd/$vhost" || stop_function

	mkdir .devilbox 2>/dev/null
	touch .devilbox/backend.cfg 2>/dev/null
	echo "conf:phpfpm:tcp:$php_version:9000" >.devilbox/backend.cfg
	reload_watcherd_message
}

# This will change back the PHP version of a vhost to the default one by remove the `backend.cfg` file
function php_default() {
	local vhost
	local php_version

	vhost=$(ask_vhost_name "$1")

	cd "/shared/httpd/$vhost" || stop_function

	rm -f .devilbox/backend.cfg 2>/dev/null
	reload_watcherd_message
}

# Make sure the PHP container is current before next steps
function ensure_current_php_container() {
	local php_version

	php_version=$(ask_php_version "$1")

	if ! is_php_container_current "$php_version"; then
		current=$(php_version)
		echo_error "PHP container mismatch! You are currently inside $(style "$current" bg-white bold) container."
		echo_message "To switch to $(style " $php_version " bg-white bold), $(style " exit " bg-white bold) this container first then run $(style " ./up.sh $php_version " bg-white bold)."
		stop_function
	fi
}

# Install composer dependencies when necessary
function composer_install {
	# Some Symfony projects has "bin/composer" binary which is sort of wrapper for composer
	if { [ -f "composer.lock" ] || [ -f "composer.json" ]; } && [ ! -d "vendor" ]; then
		if { [ -f "bin/composer" ] && php bin/composer install; } || composer install; then
			echo_success "Successfully installed dependencies!"
		fi
	fi
}
