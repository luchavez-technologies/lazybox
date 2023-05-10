# This will change the port where the node app will be expected to run on
function port_change() {
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "Please enter port number where the app will run:"
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

# Install npm dependencies when necessary
function npm_install {
  if [ -f package.lock ] && [ ! -d node_modules ]; then
    npm install && echo_success "Successfully installed dependencies!"
  fi
}

# Install npm dependencies when necessary
function yarn_install {
  if [ -f yarn.lock ] && [ ! -d node_modules ]; then
    yarn && echo_success "Successfully installed dependencies!"
  fi
}

# Run npm script
function npm_run {
  if [ -f package-lock.json ] && [ -d node_modules ] && [ -n "$1" ]; then
    npm run "$1"
  fi
}

# Run npm script
function yarn_run {
  if [ -f yarn.lock ] && [ -d node_modules ] && [ -n "$1" ]; then
    yarn "$1"
  fi
}

# Run npm or yarn script
function npm_or_yarn_run() {
  if [ -n "$1" ]; then
    npm_run "$1"
    yarn_run "$1"
  fi
}
