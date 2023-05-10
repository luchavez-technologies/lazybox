# Create and run a new NextJS app
function next_new() {
  next_version="latest"
  next_port=3000
  if [ $# -eq 0 ]; then
    echo "Please enter NextJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Please enter NextJS version (default: 'latest'):"
    read -r version

    if [ -n "$version" ]; then
        next_version=$version
    fi

    echo "Note: Make sure that the port $next_port is not taken. If taken, specify a new port below."
    echo "Please enter NextJS port (default: '$next_port'):"
    read -r port

    if [ -n "$port" ]; then
        next_port=$port
    fi
  else
    if [ -n "$1" ]; then
      name=$1
    fi

    if [ -n "$2" ]; then
      next_version=$2
    fi

    if [ -n "$3" ]; then
      next_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  npx create-next-app@"$next_version" "$name" 2>/dev/null

  port_change "$name" "$next_port"

  cd "$name" || stop_function

  text_replace "\"next dev\"" "\"next dev --port $next_port\"" "package.json"

  welcome_to_new_app_message "$name"

  npm run dev
}

# Clone and run a NextJS app
function next_clone() {
  url=""
  next_port=3000
  if [ $# -eq 0 ]; then
    echo "Please enter Git URL of your NextJS app:"
    read -r url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    echo "Please enter NextJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $next_port is not taken. If taken, specify a new port below."
    echo "Please enter NextJS port (default: '$next_port'):"
    read -r port

    if [ -n "$port" ]; then
      next_port=$port
    fi
  else
    if [ -n "$1" ]; then
      url=$1
    fi

    if [ -n "$2" ]; then
      name=$2
    fi

    if [ -n "$3" ]; then
      next_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$next_port"

  cd "$name" || stop_function

  # yarn or npm
  runner=""
  if [ -f "yarn.lock" ]; then
    runner="yarn"
  else
    runner="npm"
  fi

  text_replace "\"next dev\"" "\"next dev --port $next_port\"" "package.json"

  $runner install 2>/dev/null

  welcome_to_new_app_message "$name"

  $runner run dev
}
