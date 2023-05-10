# This will replace a text with another text inside a file
function text_replace() {
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
    if [ -n "$1" ]; then
      search=$1
    else
      echo_error "The search text is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      replace=$2
    else
      echo_error "The replace text is empty!"
      stop_function
    fi

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

  # check if text actually exists
  if grep -q "$search" "$file_name"; then
    sed -i "s/$search/$replace/g" "$file_name" 2>/dev/null
    echo_success "✅ Successfully replaced '$search' with '$replace'."
  else
    echo_error "❌ Failed to find '$search' in '$file_name'."
  fi
}

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function symlink() {
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "Please enter PHP app name (default: '$vhost'):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  else
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      app=$2
    else
      app=$1
    fi
  fi

  cd /shared/httpd || stop_function

  directory="$vhost/$app/public"
  if [ -d "$directory" ]; then
    cd "$vhost" || stop_function

    # symlink public folder of the new laravel app to htdocs
    if ln -s "$app/public" htdocs 2>/dev/null; then
      echo_success "👍 Successfully symlinked '$app/public' to 'htdocs'."
    else
      echo_error "👎 Failed to symlink '$app/public' to 'htdocs'."
    fi
  fi
}

# Display error message
function echo_error() {
  if [ -n "$1" ]; then
    echo -e "\e[31m$1\e[0m"
  else
    echo "The message is empty!"
  fi
}

# Display success message
function echo_success() {
  if [ -n "$1" ]; then
    echo -e "\e[32m$1\e[0m"
  else
    echo "The message is empty!"
  fi
}

# Stop function execution
function stop_function() {
  kill -INT $$
}

# Welcome user to new app
function welcome_to_new_app_message() {
  if [ -n "$1" ]; then
    reload_watcherd_message
    echo_success "👋 Welcome to your new app ($1)! Happy coding! 🎉"
    echo_success "🚀 Here's your app URL 👉👉👉 \033[1mhttps://$1.dvl.to"
  else
    echo_error "The vhost is empty!"
  fi
}

# Reload watcherd message
function reload_watcherd_message() {
  echo_success "🔄 Click 'Reload' on 'watcherd' daemon on C&C page 👉👉👉 \033[1mhttp://localhost/cnc.php"
}

# Install project dependencies
function project_install() {
    npm_install
    yarn_install
    composer_install
}
