source /etc/bashrc-devilbox.d/workflows/php-version.sh

# Run all start.sh files on all vhosts
for vhost in /shared/httpd/*; do
	php_version=$(php_version)
	if [ -f "$vhost/start.sh" ]; then
		cfg="$vhost/.devilbox/backend.cfg"

		# If the backend.cfg file exists, then check if container specified matches the current PHP container
		if [ -f "$cfg" ]; then
			container=$(grep -m 1 -o ':php[0-9]*:' "$cfg" | sed 's/^.//;s/.$//')
			if [ "$container" != "$php_version" ]; then
			    continue;
			fi
		# If there's no backend.cfg, then check if the current PHP container is called "php"
		elif [ "$php_version" != "php" ]; then
		    continue;
		fi

		su -c "cd $vhost; ./start.sh" -l devilbox
	fi
done
