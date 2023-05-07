alias pa='php artisan'
alias pamfs='pa migrate:fresh --seed'
alias pamfspi='pamfs && pa passport:install'

# Create and run a new Laravel app
function laravel_new() {
  laravel_version=""
  php_version=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for app name
    echo "Please enter Laravel app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    # ask for Laravel version
    echo "Please enter Laravel version (default: 'latest'):"
    read -r laravel_version

    # ask for Laravel version
    echo "Please enter PHP container to run the app on (default: 'php'):"
    read -r php_version
  else
    # set as name if input is not empty
    if [ -n "$1" ]; then
      name=$1
    fi

    # set as laravel_version if input is not empty
    if [ -n "$2" ]; then
      laravel_version=$2
    fi

    # set as php_version if input is not empty
    if [ -n "$3" ]; then
      php_version=$3
    fi
  fi

  version=""
  if [ -n "$laravel_version" ]; then
    version=":^$laravel_version"
    # check if the version contains a period
    if [[ ! "$laravel_version" =~ . ]]; then
      version+=".0"
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  composer create-project "laravel/laravel$version" "$name" 2>/dev/null

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  # cd to project
  cd "$name" || stop_function

  env=".env"
  # run migrate:fresh --seed if .env exists
  if [ -f $env ]; then
    replace_db_host
    replace_db_name "$name"
    replace_redis_host
    pa migrate --seed 2>/dev/null
  fi

  # exit message
  echo_success "👋 Welcome to your new app ($name)! Happy coding! 🎉"
  echo_success "🚀 Here's your app URL 👉 \033[1mhttps://$name.dvl.to"
}

# Clone and run a Laravel app
function laravel_clone() {
  php_version=""
  url=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for Git URL
    echo "Please enter Git URL of your Laravel app:"
    read -r url
    # check if input is empty
    if [ -z "$url" ]; then
      # do something if input is empty
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    # ask for app name
    echo "Please enter app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    # ask for Laravel version
    echo "Please enter PHP container where the app should run (default: 'php'):"
    read -r php_version
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      url=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      # do something if input is empty
      name=$2
    fi

    # check if input is not empty
    if [ -n "$3" ]; then
      # do something if input is empty
      php_version=$3
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  git clone "$url" "$name"

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  # cd to project
  cd "$name" || stop_function

  # install dependencies
  composer install 2>/dev/null

  # copy .env.example to .env
  env=".env"
  if [ ! -f $env ]; then
      cp .env.example "$env" 2>/dev/null
  fi

  # run migrate:fresh --seed if .env exists
  if [ -f $env ]; then
    replace_db_host
    replace_db_name "$name"
    replace_redis_host
    pa migrate --seed 2>/dev/null
  fi

  # exit message
  echo_success "👋 Welcome to your newly cloned app ($name)! Happy coding! 🎉"
  echo_success "🚀 Here's your app URL 👉 \033[1mhttps://$name.dvl.to"
}

# Replace DB_HOST on .env with Devilbox's DB URL
function replace_db_host() {
  text_replace "DB_HOST=127.0.0.1" "DB_HOST=172.16.238.12" .env 2>/dev/null
}

# Replace DB_DATABASE on .env with vhost name
function replace_db_name() {
  if [ $# -eq 0 ]; then
    echo "Please enter Laravel app name:"
    read -r app

    if [ -z "$app" ]; then
      echo_error "The app name is empty!"
      stop_function
    fi
  else
    if [ -n "$1" ]; then
      app=$1
    else
      echo_error "The app name is empty!"
      stop_function
    fi
  fi

  app=${app//-/_}
  text_replace "DB_DATABASE=laravel" "DB_DATABASE=$app" .env 2>/dev/null
}

# Replace REDIS_HOST on .env with Devilbox's DB URL
function replace_redis_host() {
  text_replace "REDIS_HOST=127.0.0.1" "REDIS_HOST=172.16.238.14" .env 2>/dev/null
}
