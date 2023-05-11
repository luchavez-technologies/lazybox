# This will change the port where the node app will be expected to run on
function port_change() {
  if [ $# -eq 0 ]; then
    echo "👀 Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "👀 Please enter port number where the app will run:"
    read -r port

    if [ -z "$port" ]; then
      echo_error "The port number is empty!"
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
      port=$2
    else
      echo_error "The port number is empty!"
      stop_function
    fi
  fi

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    if [ -n "$port" ]; then
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:rproxy:http:172.16.238.10:$port" > .devilbox/backend.cfg
      reload_watcherd_message
    fi
  fi
}

# Execute npm or yarn commands
function npm_yarn() {
  args=""
  if [ $# -gt 0 ]; then
    args=$*
  fi

  prepend=""
  if [ -f package-lock.json ]; then
    prepend=npm
  elif [ -f yarn.lock ]; then
    prepend=yarn
  elif [ -f package.json ]; then
    prepend=npm
  fi

  if [ -n "$prepend" ]; then
    echo_success "🙏 \033[1m$prepend $args"
    $prepend $args
  fi
}

# Install NPM dependencies
function npm_yarn_install() {
  args=""
  if [ $# -gt 0 ]; then
    args=$*
  fi

  if [ ! -d node_modules ]; then
    npm_yarn install $args
  else
    echo_error "Dependencies are already installed."
  fi
}

# Install NPM dependencies for production
function npm_yarn_install_production() {
  npm_yarn_install --production
}

# Execute npm or yarn commands
function npm_yarn_run() {
  args=""
  if [ $# -eq 0 ]; then
    echo_error "Missing arguments!"
  elif [ -d node_modules ]; then
    args=$*
    npm_yarn run $args
  else
    echo_error "Dependencies are not yet installed."
  fi
}
