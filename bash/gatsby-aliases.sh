# Create and run a new GatsbyJS app
function gatsby_new() {
  gatsby_version="latest"
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for app name
    echo "Please enter GatsbyJS app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    # ask for GatsbyJS version
    echo "Please enter GatsbyJS version (default: 'latest'):"
    read -r gatsby_version
  else
    # set as name input is not empty
    if [ -n "$1" ]; then
      name=$1
    fi

    # set as gatsby_version if input is not empty
    if [ -n "$2" ]; then
      gatsby_version=$2
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  npx gatsby@"$gatsby_version" new "$name"

  # add the devilbox config
  port_change "$name" 8000

  # cd to project
  cd "$name" || stop_function

  # make sure to expose GatsbyJS to the Docker network
  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0\"" "package.json"

  # exit message
  echo_success "Welcome to your new app ($name)! Happy coding! 🎉"
  echo_success "Here's your app URL: https://$name.dvl.to"

  # run the app
  npm run develop
}

# Clone and run a GatsbyJS app
function gatsby_clone() {
  url=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for Git URL
    echo "Please enter Git URL of your GatsbyJS app:"
    read -r url
    # check if input is empty
    if [ -z "$url" ]; then
      # do something if input is empty
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    # ask for app name
    echo "Please enter GatsbyJS app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      # do something if input is empty
      name="app-$RANDOM"
    fi
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
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  git clone "$url" "$name"

  # add the devilbox config
  port_change "$name" 8000

  # cd to project
  cd "$name" || stop_function

  # yarn or npm
  runner=""
  if [ -f "yarn.lock" ]; then
    runner="yarn"
  else
    runner="npm"
  fi

  # make sure to expose GatsbyJS to the Docker network
  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0\"" "package.json"

  # install dependencies
  $runner install

  # exit message
  echo_success "Welcome to your newly cloned app ($name)! Happy coding! 🎉"
  echo_success "Here's your app URL: https://$name.dvl.to"

  # run the app
  $runner run develop
}
