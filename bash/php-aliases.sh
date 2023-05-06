# This will change the PHP container where the vhost will run on
function php_change() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "Please enter PHP container where the app should run:"
    read -r php_version

    if [ -z "$php_version" ]; then
      echo_error "The container name is empty."
      stop_function
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      php_version=$2
    else
      echo_error "The container name is empty."
      stop_function
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    # change directory
    cd "$vhost" || stop_function

    # copy .devilbox/backend.cfg
    if [ -n "$php_version" ]; then
      # do something if input is empty
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:phpfpm:tcp:$php_version:9000" > .devilbox/backend.cfg
      echo "✅ Go to C&C page then click 'Reload' on 'watcherd' daemon: http://localhost/cnc.php"
    fi
  fi
}

# This will change back the PHP version of a vhost to the default one by remove the `backend.cfg` file
function php_default() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      vhost=$1
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    # change directory
    cd "$vhost" || stop_function

    # remove .devilbox folder
    rm -rf .devilbox
    echo_success "✅ Go to C&C page then click 'Reload' on 'watcherd' daemon: http://localhost/cnc.php"
  fi
}
