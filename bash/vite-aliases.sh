# Create and run a new ViteJS app
function vite_new() {
  vite_version="latest"
  vite_port=5173
  if [ $# -eq 0 ]; then
    echo "👀 Please enter ViteJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "👀 Please enter ViteJS $(style "version" underline bold) (default: $(style "latest" bold blue)):"
    read -r version

    if [ -n "$version" ]; then
        vite_version=$version
    fi

    echo "Note: Make sure that the port $vite_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter ViteJS $(style "port number" underline bold) (default: $(style "$vite_port" bold blue)):"
    read -r port

    if [ -n "$port" ]; then
        vite_port=$port
    fi
  else
    if [ -n "$1" ]; then
      name=$1
    fi

    if [ -n "$2" ]; then
      vite_version=$2
    fi

    if [ -n "$3" ]; then
      vite_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  style "🚀 Creating your project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx create-vite@"$vite_version" "$name" 2>/dev/null

  port_change "$name" "$vite_port"

  cd "$name" || stop_function

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $vite_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a ViteJS app
function vite_clone() {
  url=""
  vite_port=5173
  branch="develop"
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "Git URL" underline bold) of your ViteJS app:"
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

    echo "👀 Please enter ViteJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $vite_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter ViteJS $(style "port number" underline bold) (default: $(style "$vite_port" bold blue)):"
    read -r port

    if [ -n "$port" ]; then
        vite_port=$port
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

    if [ -n "$3" ]; then
      vite_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  style "🚀 Creating your project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"
  git checkout "$branch"

  port_change "$name" "$vite_port"

  cd "$name" || stop_function

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $vite_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
