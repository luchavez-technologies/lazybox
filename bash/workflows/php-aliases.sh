# This will change the PHP container where the vhost will run on
function php_change() {
  if [ -n "$1" ]; then
    vhost=$1
  else
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  fi

  if [ -n "$2" ]; then
    php_version=$2
  else
    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) where the app should run:"
    read -r php_version

    if [ -z "$php_version" ]; then
      echo_error "The container name is empty!"
      stop_function
    fi
  fi

  # Validate if "php_version" input matches the current PHP container
  if ! is_php_container_valid "$php_version"; then
    echo_error "Invalid PHP container name: $(style "$php_version" bold)"
    stop_function
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
  if [ -n "$1" ]; then
    vhost=$1
  else
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  fi

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    # remove .devilbox/backend.cfg file
    rm -f .devilbox/backend.cfg 2>/dev/null
    reload_watcherd_message
  fi
}

# Get the current PHP container name
function php_version() {
  declare -A versions
  versions['172.16.238.10']='php'
  versions['172.16.238.201']='php54'
  versions['172.16.238.202']='php55'
  versions['172.16.238.203']='php56'
  versions['172.16.238.204']='php70'
  versions['172.16.238.205']='php71'
  versions['172.16.238.206']='php72'
  versions['172.16.238.207']='php73'
  versions['172.16.238.208']='php74'
  versions['172.16.238.209']='php80'
  versions['172.16.238.210']='php81'
  versions['172.16.238.211']='php82'

  ip=$(ip_address)
  echo "${versions[$ip]}"
}

# Get the default PHP container name
function php_server() {
  version=$PHP_SERVER
  echo "php${version//./}"
}

# Check if the PHP container name input matches the current container
function is_php_container_current() {
  if [ -z "$1" ] || ! is_php_container_valid "$1"; then
    return 1
  fi

  input=$1
  current=$(php_version)

  if [ "$input" == "$current" ]; then
    return 0
  fi

  return 1
}

# Make sure the PHP container is current before next steps
function ensure_current_php_container() {
  local php_version

  php_version=$(ask_php_version "$1")

  if ! is_php_container_current "$php_version"; then
    current=$(php_version)
    echo_error "PHP container mismatch! You are currently inside $(style "$current" bold blue) container."
    echo "✋ To switch to $(style "$php_version" bold blue), exit this container first then run $(style "./up.sh $php_version" bold blue)."
    stop_function
  fi
}

# Install composer dependencies when necessary
function composer_install {
  # Some Symfony projects has "bin/composer" binary which is sort of wrapper for composer
  if { [ -f "composer.lock" ] || [ -f "composer.json" ]; } && [ ! -d "vendor" ]; then
    if { hash bin/composer && php bin/composer install; } || composer install; then
      echo_success "Successfully installed dependencies!"
    fi
  fi
}
