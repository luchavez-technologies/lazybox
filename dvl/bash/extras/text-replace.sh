# This will replace a text with another text inside a file
function text_replace() {
	local search
	local replace
	local file_name
	local content

	search=${1:-$(ask "Please enter the search text")}

	if [ -z "$search" ]; then
		echo_error "The search text is empty!"
		return 1
	fi

	replace=${2:-$(ask "Please enter the replace text")}

	if [ -z "$replace" ]; then
		echo_error "The replace text is empty!"
		return 1
	fi

	file_name=${3:-$(ask "Please enter the file name")}

	if [ -z "$file_name" ]; then
		echo_error "The file name is empty!"
		return 1
	elif [ ! -f "$file_name" ]; then
		echo_error "The file does not exist!"
		return 1
	fi

	# Check if text actually exists
	if text_exists "$search" "$file_name"; then
		content=$(sed "s|$search|$replace|g" "$file_name")
		if [ -n "$content" ] && echo "$content" > "$file_name"; then
		    replace=$(style "$replace" bold blue | tr '\n' ' ')
			echo_success "Successfully replaced $(style "$search" bold blue) with $replace."
			return 0
		fi
	fi

	return 1
}

# Replace text in symlinked /.env file
function env_text_replace() {
	local  search
	local replace
	local env="/.env"
    local tmp="/tmp$env"

	search=${1:-$(ask "Please enter the search text")}

	if [ -z "$search" ]; then
		echo_error "The search text is empty!"
		return 1
	fi

	replace=${2:-$(ask "Please enter the replace text")}

	if [ -z "$replace" ]; then
		echo_error "The replace text is empty!"
		return 1
	fi

	cp -f "$env" "$tmp"
	text_replace "$search" "$replace" "$tmp"
	cat "$tmp" > "$env"
	rm "$tmp"
}

# This will check if a text exists inside a file
function text_exists() {
	local search

	search=${1:-$(ask "Please enter the search text")}

  	if [ -z "$search" ]; then
  		echo_error "The search text is empty!"
  		return 1
  	fi

  	file_name=${2:-$(ask "Please enter the file name")}

	if [ -z "$file_name" ]; then
		echo_error "The file name is empty!"
		return 1
	elif [ ! -f "$file_name" ]; then
		echo_error "The file does not exist!"
		return 1
	fi

	if grep -q "$search" "$file_name"; then
		return 0
	else
		return 1
	fi
}
