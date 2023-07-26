# Make devilbox user the owner of a folder
function own_directory() {
	if [ -n "$1" ] && [ -d "$1" ]; then
		directory="$1"
		owner="devilbox"
		current_owner=$(stat -c '%U' "$directory")

		if [ "$owner" != "$current_owner" ]; then
			if sudo chown "$owner":"$owner" "$directory" && sudo chmod 0755 "$directory"; then
				echo_success "Successfully set $(style "$owner" bold blue) as owner of $(style "$directory" bold blue)."
			else
				echo_error "Failed to set $(style "$owner" bold blue) as owner of $(style "$directory" bold blue)."
			fi
		fi
	else
		echo_error "The $directory directory does not exist!"
	fi
}

# Make devilbox user the owner of a file
function own_file() {
	if [ -n "$1" ] && [ -f "$1" ]; then
		file="$1"
		owner="devilbox"
		current_owner=$(stat -c '%U' "$file")

		if [ "$owner" != "$current_owner" ]; then
			if sudo chown "$owner":"$owner" "$file"; then
				echo_success "Successfully set $(style "$owner" bold blue) as owner of $(style "$file" bold blue)."
			else
				echo_error "Failed to set $(style "$owner" bold blue) as owner of $(style "$file" bold blue)."
			fi
		fi
	else
		echo_error "The $file file does not exist!"
	fi
}
