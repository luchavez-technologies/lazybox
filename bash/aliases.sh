# Import extras

source /etc/bashrc-devilbox.d/extras/arrays.sh
source /etc/bashrc-devilbox.d/extras/strings.sh
source /etc/bashrc-devilbox.d/extras/ports.sh
source /etc/bashrc-devilbox.d/extras/style.sh
source /etc/bashrc-devilbox.d/extras/text-replace.sh

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function symlink() {
  local vhost
  local app
  local vhost_directory
  local app_directory
  local web_root
  local file

  vhost=$(ask_vhost_name "$1")
  app=$(ask_app_name "PHP" "$2" "$vhost")

  # Check if vhost and app exists
  vhost_directory="/shared/httpd/$vhost"
  app_directory="$vhost_directory/$app"
  web_root=""
  file=""

  cd "$vhost_directory" || stop_function

  # If public folder does not exist, always ask until an existing directory is provided
  roots=("public" "web" "webroot")
  web_root=""
  for root in "${roots[@]}"
  do
    if [ -d "$app_directory/$root" ]; then
      web_root="$root"
      break
    fi
  done

  while [ -z "$web_root" ]; do
    echo "👀 Please enter $(style "web root" underline bold) directory:"
    read -r root

    if [ -d "$app_directory/$root" ]; then
      web_root="$root"
      break
    else
      echo_error "The $(style "$root" underline bold) directory does not exist!"
    fi
  done

  # Check if index files exist
  indexes=("index.html" "index.htm" "index.php" "app.php")
  for index in "${indexes[@]}"
  do
    if [ -f "$app_directory/$web_root/$index" ]; then
      file="$index"
      break
    fi
  done

  while [ -z "$file" ]; do
    echo "👀 Please enter $(style "entry point" underline bold) file:"
    read -r index

    if [ -f "$app_directory/$web_root/$index" ]; then
      file="$index"
      break
    else
      echo_error "The $(style "$index" underline bold) file does not exist!"
    fi
  done

  # Do the symlink
  if ln -s "$app_directory/$web_root" "$vhost_directory/htdocs" 2>/dev/null; then
    echo_success "Successfully symlinked $(style "$app_directory/$web_root" bold blue) to $(style "$vhost_directory/htdocs" bold blue)."
  else
    echo_error "Failed to symlink $(style "$app_directory/$web_root" bold blue) to $(style "$vhost_directory/htdocs" bold blue)."
  fi

  # Copy nginx yml to vhost if file is not index.php
  cp_backend_web_server_yml "$vhost" "$app" "$web_root" "$file"
  return 0
}

# Copy nginx or apache yml to vhost (vhost)
function cp_backend_web_server_yml() {
  local vhost
  local app

  vhost=$(ask_vhost_name "$1")
  app=$(ask_app_name "PHP" "$vhost" "$2")

  if [ -n "$3" ]; then
      web_root=$3
  else
    echo "👀 Please enter $(style "web root" underline bold) directory:"
    read -r web_root
  fi

  if [ -z "$web_root" ]; then
    web_root="public"
  fi

  if [ -n "$4" ]; then
    file=$4
  else
    echo "👀 Please enter $(style "entry point" underline bold) file:"
    read -r file
  fi

  if [ -z "$file" ]; then
    file="index.php"
  fi

  # Check if vhost and app exists
  vhost_directory="/shared/httpd/$vhost"
  app_directory="$vhost_directory/$app"

  if [ "$file" != "index.php" ]; then
    # Make sure the .devilbox folder exists
    mkdir "$vhost_directory/.devilbox" 2>/dev/null

    yml_example=$(get_vhost_gen_yml_name vhost)
    yml=${yml_example%%-example*}

    if cp "/cfg/vhost-gen/$yml_example" "$vhost_directory/.devilbox/$yml"; then
      echo_success "Successfully copied $(style "$yml_example" bold blue) to $(style "$vhost_directory/.devilbox/$yml" bold blue)."
      text_replace "__INDEX__;" "$file __INDEX__;" "$vhost_directory/.devilbox/$yml"
      text_replace "index.php" "$file" "$vhost_directory/.devilbox/$yml"
    else
      echo_error "Failed to copy $(style "$yml_example" bold blue) to $(style "$vhost_directory/.devilbox/$yml" bold blue)."
    fi
  fi
}

# Copy nginx or apache yml to vhost (rproxy)
function cp_frontend_web_server_yml() {
  local vhost
  local php_version
  local port
  local vhost_directory
  local yml_example
  local yml
  local key
  local php_version_port

  # VHost Name
  vhost=$(ask_vhost_name "$1")

  # PHP Version
  php_version_list
  php_version=$(ask_php_version "$2")

  # Port Number
  port=$(ask_port "$3")

  # Check if vhost and app exists
  vhost_directory="/shared/httpd/$vhost"

  # Make sure the .devilbox folder exists
  mkdir "$vhost_directory/.devilbox" 2>/dev/null

  yml_example=$(get_vhost_gen_yml_name rproxy)
  yml=${yml_example%%-example*}

  # Copy the vhost-gen yml to .devilbox
  if [ ! -f "$vhost_directory/.devilbox/$yml" ] && cp "/cfg/vhost-gen/$yml_example" "$vhost_directory/.devilbox/$yml"; then
    echo_success "Successfully copied $(style "$yml_example" bold blue) to $(style "$vhost_directory/.devilbox/$yml" bold blue)."
    text_replace "php:8000" "$php_version:$port" "$vhost_directory/.devilbox/$yml"
    return 0
  fi

  # Replace if the file already exists
  key="proxy_pass http://"
  php_version_port=$(grep "$key" "$vhost_directory/.devilbox/$yml" | awk -F "$key" '{print $2}')

  if [ -n "$php_version_port" ]; then
    text_replace "$php_version_port" "$php_version:$port;" "$vhost_directory/.devilbox/$yml"
    return 0
  fi

  return 1
}

# Get nginx/apache example yml name
function get_vhost_gen_yml_name() {
  if [ -n "$1" ]; then
    type=$1
  else
    types=("vhost" "rproxy")
    while true; do
      echo "Here are the vhost types: $(style "${types[*]}" bold blue)"
      echo "👀 Please enter $(style "vhost type" underline bold):"
      read -r type

      if [ -n "$type" ] && printf '%s\n' "${types[@]}" | grep -xq "$type"; then
        break
      fi

      echo_error "Invalid vhost type!"
    done
  fi

  declare -A ymls

  ymls["apache-2.2"]="apache22.yml-example"
  ymls["apache-2.4"]="apache24.yml-example"
  ymls["nginx-stable"]="nginx.yml-example"
  ymls["nginx-mainline"]="nginx.yml-example"

  echo "${ymls[$HTTPD_SERVER]}-$type"
}

function env_text_replace() {
  if [ -n "$1" ]; then
    search=$1
  else
    echo "👀 Please enter the search text:"
    read -r search

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      return 1
    fi
  fi

  if [ -n "$2" ]; then
    replace=$2
  else
    echo "👀 Please enter the replace text:"
    read -r replace

    if [ -z "$replace" ]; then
      echo_error "The replace text is empty!"
      return 1
    fi
  fi

  env="/.env"
  tmp="/tmp$env"

  cp -f "$env" "$tmp"
  text_replace "$search" "$replace" "$tmp"
  cat "$tmp" > "$env"
  rm "$tmp"
}

# Set Ngrok Settings
function ngrok_set() {
  env="/.env"
  #NGROK_HTTP_TUNNELS=laravel.dvl.to:httpd:80
  #NGROK_AUTHTOKEN=2QVMa1gQmwIluGDcht7KDExh4Vg_4przyoQd2JLizm6anPgJv
  current_vhost_variable="NGROK_HTTP_TUNNELS="
  vhost_suffix=".dvl.to:httpd:80"
  current_token_variable="NGROK_AUTHTOKEN="
  current_vhost=$(grep "^$current_vhost_variable*" "$env")
  current_token=$(grep "^$current_token_variable*" "$env")

  vhost="${current_vhost#$current_vhost_variable}"
  token="${current_token#$current_token_variable}"

  if [ -n "$vhost" ]; then
    vhost="${vhost%$vhost_suffix}"
  fi

  echo "👀 Please enter $(style "vhost" underline bold) (default: $(style "$vhost" bold blue)):"
  read -r v

  if [ -n "$v" ]; then
    if [ -d "/shared/httpd/$v" ]; then
      vhost="$v"
      env_text_replace "$current_vhost" "$current_vhost_variable$vhost$vhost_suffix"
    else
      echo_error "The vhost does not exist!"
    fi
  fi

  echo "👀 Please enter $(style "token" underline bold) (default: $(style "$token" bold blue)):"
  read -r t

  if [ -n "$t" ]; then
    token="$t"
    env_text_replace "$current_token" "$current_token_variable$token$token_suffix"
  fi

  php_version=$(php_version)
  echo "✋ If $(style "Ngrok settings" bold blue) has been changed, exit this container first then run $(style "./up.sh $php_version" bold blue)."
}

# Stop function execution
function stop_function() {
  kill -INT $$
  return 1
}

# Install project dependencies
function project_install() {
  npm_yarn_install
  composer_install
}

# Make devilbox user the owner of a folder
function own_directory() {
  if [ -n "$1" ] && [ -d "$1" ]; then
    directory="$1"
    owner="devilbox"
    current_owner=$(stat -c '%U' "$directory")

    if [ "$owner" != "$current_owner" ]; then
      if sudo chown "$owner":"$owner" "$directory"; then
        echo_success "Successfully set $(style "$owner" bold blue) as owner of $(style "$directory" bold blue)."
      else
        echo_error "Failed to set $(style "$owner" bold blue) as owner of $(style "$directory" bold blue)."
      fi
    fi
  else
    echo_error "The $directory directory does not exist!"
  fi
}

# Make devilbox user the owner of a file
function own_file() {
  if [ -n "$1" ] && [ -f "$1" ]; then
    file="$1"
    owner="devilbox"
    current_owner=$(stat -c '%U' "$file")

    if [ "$owner" != "$current_owner" ]; then
      if sudo chown "$owner":"$owner" "$file"; then
        echo_success "Successfully set $(style "$owner" bold blue) as owner of $(style "$file" bold blue)."
      else
        echo_error "Failed to set $(style "$owner" bold blue) as owner of $(style "$file" bold blue)."
      fi
    fi
  else
    echo_error "The $file file does not exist!"
  fi
}

# Get current IP address
function ip_address() {
  hostname -I | awk '{print $1}'
}

# Get user's name from Git config
function git_name() {
  git config --global user.name || echo "stranger"
}

# Where am I?
function whereami() {
  local default="/shared/httpd"
  local absolute=$(pwd)
  local workspace=$HOST_PATH_HTTPD_DATADIR
  local relative="not found"

  if echo "$absolute" | grep -q "^$default"; then
      relative=${absolute#$default}
      relative="$workspace$relative"
  fi

  echo_style "👋 Hi, there, $(git_name)! 😉"
  echo_style "👉 Your IP address is $(style "$(ip_address)" bold underline green) a.k.a. the $(style "$(php_version)" bold underline green) container."
  echo_style "👉 Your current directory $(style "inside" bold green) the container is: $(style "$absolute" bold underline green)"
  echo_style "👉 Your current directory $(style "outside" bold green) the container is: $(style "$relative" bold underline green)"
}

# Own some directories
own_directory /var/cache
own_directory /var/log
own_directory /var/lib

# The loaded ".env" file cannot be edited using "sed" function.
# It was found out that overriding the contents via "cat" function works.
# Therefore, we just save a copy of ".env" to "/tmp" then override the original's contents.
own_file /.env
