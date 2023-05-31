# Create and run a new Vite app
function vite_new() {
  framework="ViteJS"
  version="latest"
  port=5173

  if [ -n "$1" ]; then
    name=$1
  else
    echo "👀 Please enter $framework $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi
  fi

  if [ -n "$2" ]; then
    version=$2
  else
    echo "👀 Please enter $framework $(style "version" underline bold) (default: $(style "latest" bold blue)):"
    read -r v

    if [ -n "$v" ]; then
        version=$v
    fi
  fi

  if [ -n "$3" ]; then
    port=$3
  else
    echo "Note: Make sure that the port $port is not taken. If taken, specify a new port below."
    echo "👀 Please enter $framework $(style "port number" underline bold) (default: $(style "$port" bold blue)):"
    read -r p

    if [ -n "$p" ]; then
        port=$p
    fi
  fi

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx create-vite@"$version" "$name" 2>/dev/null

  port_change "$name" "$port"

  cd "$name" || stop_function

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a Vite app
function vite_clone() {
  framework="ViteJS"
  url=""
  port=5173
  branch="develop"

  if [ -n "$1" ]; then
    url=$1
  else
    echo "👀 Please enter $(style "Git URL" underline bold) of your $framework app:"
    read -r url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi
  fi

  if [ -n "$2" ]; then
    branch=$2
  else
    echo "👀 Please enter $(style "branch name" underline bold) to checkout at (default: $(style "develop" bold blue)):"
    read -r b

    if [ -n "$b" ]; then
      branch="$b"
    fi
  fi

  if [ -n "$3" ]; then
    name=$3
  else
    echo "👀 Please enter $framework $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi
  fi

  if [ -n "$3" ]; then
    port=$3
  else
    echo "Note: Make sure that the port $port is not taken. If taken, specify a new port below."
    echo "👀 Please enter $framework $(style "port number" underline bold) (default: $(style "$port" bold blue)):"
    read -r p

    if [ -n "$p" ]; then
        port=$p
    fi
  fi

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$port"

  cd "$name" || stop_function
  git checkout "$branch" 2>/dev/null

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
