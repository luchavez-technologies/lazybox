# Create and run a new GatsbyJS app
function gatsby_new() {
  gatsby_version="latest"
  gatsby_port=8000
  if [ $# -eq 0 ]; then
    echo "👀 Please enter GatsbyJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "👀 Please enter GatsbyJS $(style "version" underline bold) (default: $(style "latest" bold blue)):"
    read -r version

    if [ -n "$version" ]; then
        gatsby_version=$version
    fi

    echo "Note: Make sure that the port $gatsby_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter GatsbyJS $(style "port number" underline bold) (default: $(style "$gatsby_port" bold blue)):"
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

  style "🚀 Creating your project...\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx gatsby@"$gatsby_version" new "$name" 2>/dev/null

  port_change "$name" "$gatsby_port"

  cd "$name" || stop_function

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $gatsby_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a GatsbyJS app
function gatsby_clone() {
  url=""
  gatsby_port=8000
  branch="develop"
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "Git URL" underline bold) of your GatsbyJS app:"
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

    echo "👀 Please enter GatsbyJS $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $gatsby_port is not taken. If taken, specify a new port below."
    echo "👀 Please enter GatsbyJS $(style "port number" underline bold) (default: $(style "$gatsby_port" bold blue)):"
    read -r port

    if [ -n "$port" ]; then
        gatsby_port=$port
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
      gatsby_port=$4
    fi
  fi

  cd /shared/httpd || stop_function

  style "🚀 Creating your project...\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$gatsby_port"

  cd "$name" || stop_function
  git checkout "$branch" 2>/dev/null

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $gatsby_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
