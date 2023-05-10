# Create and run a new GatsbyJS app
function gatsby_new() {
  gatsby_version="latest"
  gatsby_port=8000
  if [ $# -eq 0 ]; then
    echo "Please enter GatsbyJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Please enter GatsbyJS version (default: 'latest'):"
    read -r version

    if [ -n "$version" ]; then
        gatsby_version=$version
    fi

    echo "Note: Make sure that the port $gatsby_port is not taken. If taken, specify a new port below."
    echo "Please enter GatsbyJS port (default: '$gatsby_port'):"
    read -r port

    if [ -n "$port" ]; then
        gatsby_port=$port
    fi
  else
    if [ -n "$1" ]; then
      name=$1
    fi

    if [ -n "$2" ]; then
      gatsby_version=$2
    fi

    if [ -n "$3" ]; then
      gatsby_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  npx gatsby@"$gatsby_version" new "$name" 2>/dev/null

  port_change "$name" "$gatsby_port"

  cd "$name" || stop_function

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $gatsby_port\"" "package.json"

  welcome_to_new_app_message "$name"

  npm run develop
}

# Clone and run a GatsbyJS app
function gatsby_clone() {
  url=""
  gatsby_port=8000
  if [ $# -eq 0 ]; then
    echo "Please enter Git URL of your GatsbyJS app:"
    read -r url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    echo "Please enter GatsbyJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $gatsby_port is not taken. If taken, specify a new port below."
    echo "Please enter GatsbyJS port (default: '$gatsby_port'):"
    read -r port

    if [ -n "$port" ]; then
        gatsby_port=$port
    fi
  else
    if [ -n "$1" ]; then
      url=$1
    fi

    if [ -n "$2" ]; then
      name=$2
    fi

    if [ -n "$3" ]; then
      gatsby_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$gatsby_port"

  cd "$name" || stop_function

  # yarn or npm
  runner=""
  if [ -f "yarn.lock" ]; then
    runner="yarn"
  else
    runner="npm"
  fi

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $gatsby_port\"" "package.json"

  $runner install 2>/dev/null

  welcome_to_new_app_message "$name"

  $runner run develop
}
