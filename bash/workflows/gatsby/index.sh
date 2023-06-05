# Create and run a new GatsbyJS app
function gatsby_new() {
  framework="GatsbyJS"
  version="latest"
  port=8000

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

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx gatsby@"$version" new "$name" 2>/dev/null

  port_change "$name" "$port"

  cd "$name" || stop_function

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a GatsbyJS app
function gatsby_clone() {
  framework="GatsbyJS"
  url=""
  port=8000
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

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$port"

  cd "$name" || stop_function
  git checkout "$branch" 2>/dev/null

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
