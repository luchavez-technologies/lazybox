# Create and run a new AstroJS app
function astro_new() {
  astro_version="latest"
  astro_port=3000
  if [ $# -eq 0 ]; then
    echo "Please enter AstroJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Please enter AstroJS version (default: 'latest'):"
    read -r version

    if [ -n "$version" ]; then
        astro_version=$version
    fi

    echo "Note: Make sure that the port $astro_port is not taken. If taken, specify a new port below."
    echo "Please enter AstroJS port (default: '$astro_port'):"
    read -r port

    if [ -n "$port" ]; then
        astro_port=$port
    fi
  else
    if [ -n "$1" ]; then
      name=$1
    fi

    if [ -n "$2" ]; then
      astro_version=$2
    fi

    if [ -n "$3" ]; then
      astro_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  npx create-astro@"$astro_version" "$name" 2>/dev/null

  port_change "$name" "$astro_port"

  cd "$name" || stop_function

  text_replace "\"astro dev\"" "\"astro dev --host --port $astro_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a AstroJS app
function astro_clone() {
  url=""
  astro_port=3000
  if [ $# -eq 0 ]; then
    echo "Please enter Git URL of your AstroJS app:"
    read -r url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    echo "Please enter AstroJS app name (default: 'app-x'):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Note: Make sure that the port $astro_port is not taken. If taken, specify a new port below."
    echo "Please enter AstroJS port (default: '$astro_port'):"
    read -r port

    if [ -n "$port" ]; then
        astro_port=$port
    fi
  else
    if [ -n "$1" ]; then
      url=$1
    fi

    if [ -n "$2" ]; then
      name=$2
    fi

    if [ -n "$3" ]; then
      astro_port=$3
    fi
  fi

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$astro_port"

  cd "$name" || stop_function

  text_replace "\"astro dev\"" "\"astro dev --host --port $astro_port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
