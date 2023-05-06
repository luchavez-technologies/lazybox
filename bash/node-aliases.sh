# This will change the port where the node app will be expected to run on
function port_change() {
  # check if no argument is given
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
    # check if input is not empty
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      port=$2
    else
      echo_error "The port number is empty!"
      stop_function
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    # change directory
    cd "$vhost" || stop_function

    # copy .devilbox/backend.cfg
    if [ -n "$port" ]; then
      # do something if input is empty
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:rproxy:http:172.16.238.10:$port" > .devilbox/backend.cfg
      echo_success "✅ Go to C&C page then click 'Reload' on 'watcherd' daemon: http://localhost/cnc.php"
    fi
  fi
}
