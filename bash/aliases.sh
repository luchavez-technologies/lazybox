# This will replace a text with another text inside a file
function text_replace() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter the search text:"
    read -r search

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      stop_function
    fi

    echo "Please enter the replace text:"
    read -r replace

    if [ -z "$replace" ]; then
      echo_error "The replace text is empty!"
      stop_function
    fi

    echo "Please enter the file name:"
    read -r file_name

    if [ -z "$file_name" ]; then
      echo_error "The file name is empty!"
      stop_function
    elif [ ! -f "$file_name" ]; then
      echo_error "The file does not exist!"
      stop_function
    fi

  else
    # check if input is not empty
    if [ -n "$1" ]; then
      search=$1
    else
      echo_error "The search text is empty!"
      stop_function
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      replace=$2
    else
      echo_error "The replace text is empty!"
      stop_function
    fi

    # check if input is not empty
    if [ -n "$3" ]; then
      if [ -f "$3" ]; then
        file_name=$3
      else
        echo_error "The file does not exist!"
        stop_function
      fi
    else
      echo_error "The file name is empty!"
      stop_function
    fi
  fi

  # replace the text
  if sed -i "s/$search/$replace/g" "$file_name" 2>/dev/null; then
    echo_success "✅ Successfully replaced '$search' with '$replace'."
  else
    echo_error "❌ Failed to replace '$search' with '$replace'."
  fi
}

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function symlink() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty."
      stop_function
    fi

    echo "Please enter laravel app name (default: '$vhost'):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty."
      stop_function
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      app=$2
    else
      app=$1
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  directory="$vhost/$app/public"
  if [ -d "$directory" ]; then
    # cd to vhost
    cd "$vhost" || stop_function

    # symlink public folder of the new laravel app to htdocs
    if ln -s "$app/public" htdocs 2>/dev/null; then
      echo_success "Successfully symlinked $app/public to htdocs."
    else
      echo_error "Failed to symlink $app/public to htdocs."
    fi
  fi
}

# Display error message
function echo_error() {
    echo -e "\e[31m$1\e[0m"
}

# Display success message
function echo_success() {
    echo -e "\033[0;32m$1\033[0m"
}

# Stop function execution
function stop_function() {
    kill -INT $$
}
