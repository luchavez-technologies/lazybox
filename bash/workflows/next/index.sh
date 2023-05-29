# Create and run a new NextJS app
function next_new() {
  next_version="latest"
  next_port=3000
  if [ $# -eq 0 ]; then
    echo "👀 Please enter NextJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "👀 Please enter NextJS $(style "version" underline bold) (default: $(style "latest" bold blue)):"
    read -r version

    if [ -n "$version" ]; then
        next_version=$version
    fi

    echo "Note: Make sure that the port $next_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter NextJS $(style "port number" underline bold) (default: $(style "$next_port" bold blue)):"
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

  style "🚀 Creating your project...\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx create-next-app@"$next_version" "$name" 2>/dev/null

  port_change "$name" "$next_port"

  cd "$name" || stop_function

  text_replace "\"next dev\"" "\"next dev --port $next_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a NextJS app
function next_clone() {
  url=""
  next_port=3000
  branch="develop"
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "Git URL" underline bold) of your NextJS app:"
    read -r url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    echo "👀 Please enter $(style "branch name" underline bold) to checkout at (default: $(style "develop" bold blue)):"
    read -r b

    if [ -n "$b" ]; then
      branch="$b"
    fi

    echo "👀 Please enter NextJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $next_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter NextJS $(style "port number" underline bold) (default: $(style "$next_port" bold blue)):"
    read -r port

    if [ -n "$port" ]; then
      next_port=$port
    fi
  else
    if [ -n "$1" ]; then
      url=$1
    fi

    if [ -n "$2" ]; then
      branch=$2
    fi

    if [ -n "$3" ]; then
      name=$3
    fi

    if [ -n "$4" ]; then
      next_port=$4
    fi
  fi

  cd /shared/httpd || stop_function

  style "🚀 Creating your project...\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"
  git checkout "$branch"

  port_change "$name" "$next_port"

  cd "$name" || stop_function

  text_replace "\"next dev\"" "\"next dev --port $next_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
