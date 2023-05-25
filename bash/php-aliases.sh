# This will change the PHP container where the vhost will run on
function php_change() {
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "👀 Please enter $(style "PHP container" underline bold) where the app should run:"
    read -r php_version

    if [ -z "$php_version" ]; then
      echo_error "The container name is empty!"
      stop_function
    fi
  else
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      php_version=$2
    else
      echo_error "The container name is empty!"
      stop_function
    fi
  fi

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    if [ -n "$php_version" ]; then
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:phpfpm:tcp:$php_version:9000" > .devilbox/backend.cfg
      reload_watcherd_message
    fi
  fi
}

# This will change back the PHP version of a vhost to the default one by remove the `backend.cfg` file
function php_default() {
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  else
    if [ -n "$1" ]; then
      vhost=$1
    fi
  fi

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    # remove .devilbox folder
    rm -rf .devilbox
    reload_watcherd_message
  fi
}

# Get the current PHP container name
function php_version() {
  version=$PHP_VERSION
  echo "php${version//./}"
}

# Get the default PHP container name
function php_server() {
  version=$PHP_SERVER
  echo "php${version//./}"
}

# Check if the PHP container name input is valid
function is_php_container_valid() {
  if [ -z "$1" ]; then
    return 1
  fi

  input=$1

  containers=('php' 'php54' 'php55' 'php56' 'php70' 'php71' 'php72' 'php73' 'php74' 'php80' 'php81' 'php82')
  for container in "${containers[@]}"
  do
    if [ "$input" == "$container" ]; then
      return 0
    fi
  done

  return 1
}

# Check if the PHP container name input matches the current container
function is_php_container_current() {
  if [ -z "$1" ] || ! is_php_container_valid "$1"; then
    return 1
  fi

  input=$1
  current=$(php_version)
  server=$(php_server)

  # if the input is "php", compare "php_server" to "php_version"
  # if the input is not "php", compare it with "php_version"
  if [ "$input" == "php" ] && [ "$server" == "$current" ] || [ "$input" == "$current" ]; then
    return 0
  fi

  return 1
}

# Install composer dependencies when necessary
function composer_install {
  if { [ -f "composer.lock" ] || [ -f "composer.json" ]; } && [ ! -d "vendor" ]; then
    composer install && echo_success "Successfully installed dependencies!"
  fi
}
