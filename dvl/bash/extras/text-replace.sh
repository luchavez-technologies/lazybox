# This will replace a text with another text inside a file
function text_replace() {
  if [ -n "$1" ]; then
    search=$1
  else
    search=$(ask "Please enter the search text")

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      return 1
    fi
  fi

  if [ -n "$2" ]; then
    replace=$2
  else
    replace=$(ask "Please enter the replace text")

    if [ -z "$replace" ]; then
      echo_error "The replace text is empty!"
      return 1
    fi
  fi

  if [ -n "$3" ]; then
    if [ -f "$3" ]; then
      file_name=$3
    else
      echo_error "The file does not exist!"
      return 1
    fi
  else
    file_name=$(ask "Please enter the file name")

    if [ -z "$file_name" ]; then
      echo_error "The file name is empty!"
      return 1
    elif [ ! -f "$file_name" ]; then
      echo_error "The file does not exist!"
      return 1
    fi
  fi

  # Check if text actually exists
  if text_exists "$search" "$file_name" && { sed -i "s|$search|$replace|g" "$file_name" 2>/dev/null || sed -i "" "s|$search|$replace|g" "$file_name" 2>/dev/null; }; then
    replace=$(style "$replace" bold blue | tr '\n' ' ')
    echo_success "Successfully replaced $(style "$search" bold blue) with $replace."
    return 0
  fi

  return 1
}

# Replace text in symlinked /.env file
function env_text_replace() {
  if [ -n "$1" ]; then
    search=$1
  else
    search=$(ask "Please enter the search text")

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      return 1
    fi
  fi

  if [ -n "$2" ]; then
    replace=$2
  else
    replace=$(ask "Please enter the replace text")

    if [ -z "$replace" ]; then
      echo_error "The replace text is empty!"
      return 1
    fi
  fi

  env="/.env"
  tmp="/tmp$env"

  cp -f "$env" "$tmp"
  text_replace "$search" "$replace" "$tmp"
  cat "$tmp" > "$env"
  rm "$tmp"
}

# This will check if a text exists inside a file
function text_exists() {
  if [ -n "$1" ]; then
      search=$1
  else
    search=$(ask "Please enter the search text")

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      return 1
    fi
  fi

  if [ -n "$2" ]; then
    if [ -f "$2" ]; then
      file_name=$2
    else
      echo_error "The file does not exist!"
      return 1
    fi
  else
    file_name=$(ask "Please enter the file name")

    if [ -z "$file_name" ]; then
      echo_error "The file name is empty!"
      return 1
    elif [ ! -f "$file_name" ]; then
      echo_error "The file does not exist!"
      return 1
    fi
  fi

  if grep -q "$search" "$file_name"; then
    return 0
  else
    return 1
  fi
}
