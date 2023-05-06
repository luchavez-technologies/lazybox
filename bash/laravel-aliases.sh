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
  composer create-project laravel/laravel$version "$name"

  # symlink and add devilbox config
  symlink "$name" "$name"
  php_change "$name" "$php_version"

  # cd to project
  cd "$name" || stop_function

  # exit message
  echo_success "Welcome to your new app ($name)! Happy coding! 🎉"
  echo_error "Here's your app URL: https://$name.dvl.to"
}

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
  php_change "$name" "$php_version"

  # cd to project
  cd "$name" || stop_function

  # exit message
  echo_success "Welcome to your newly cloned app ($name)! Happy coding! 🎉"
  echo_success "Here's your app URL: https://$name.dvl.to"
}
