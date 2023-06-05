# This will change the port where the node app will be expected to run on
function port_change() {
  local php_version
  local vhost
  local port

  # VHost Name
  vhost=$(ask_vhost_name "$1")

  # Port Number
  port=$(port_ask "$2")

  php_version=$(ask_php_version "$3")

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    mkdir .devilbox 2>/dev/null

    # For backend.cfg
    touch .devilbox/backend.cfg 2>/dev/null
    echo "conf:rproxy:http:$php_version:$port" > .devilbox/backend.cfg

    # For nginx.yml (or apache.yml)
    cp_frontend_web_server_yml "$vhost" "$php_version" "$port"

    reload_watcherd_message
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
    style "🙏 $prepend $args" bold green
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

# Run project (NodeJS apps)
function project_start() {
  scripts=("dev" "develop" "development" "start")

  for script in "${scripts[@]}"
  do
    if grep -q "\"$script\"" package.json ; then
      npm_yarn_run "$script"
      break
    fi
  done
}

# Set devilbox as the owner of /opt/nvm directory
function own_nvm() {
  own_directory /opt/nvm
}

# Own NVM automatically by devilbox user
own_nvm
