# Import extras
source /etc/bashrc-devilbox.d/extras/style.sh
source /etc/bashrc-devilbox.d/extras/text-replace.sh

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function symlink() {
  if [ -n "$1" ]; then
    vhost=$1
  else
    echo "👀 Please enter $(style "vhost" underline bold):"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  fi

  if [ -n "$2" ]; then
    app=$2
  else
    echo "👀 Please enter PHP $(style "app name" underline bold) (default: $(style "$vhost" bold blue)):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  fi

  # Check if vhost and app exists
  vhost_directory="/shared/httpd/$vhost"
  app_directory="$vhost_directory/$app"
  web_root=""
  file=""
  if [ -d "$app_directory" ]; then
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
    cp_vhost_gen_yml "$vhost" "$app" "$web_root" "$file"
  fi
}

function cp_vhost_gen_yml() {
  if [ -n "$1" ]; then
    vhost=$1
  else
    echo "👀 Please enter $(style "vhost" underline bold):"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi
  fi

  if [ -n "$2" ]; then
    app=$2
  else
    echo "👀 Please enter PHP $(style "app name" underline bold) (default: $(style "$vhost" bold blue)):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  fi

  if [ -n "$3" ]; then
      web_root=$3
  else
    echo "👀 Please enter $(style "web root" underline bold) directory:"
    read -r web_root

    if [ -z "$web_root" ]; then
      web_root="public"
    fi
  fi

  if [ -n "$4" ]; then
    file=$4
  else
    echo "👀 Please enter $(style "entry point" underline bold) file:"
    read -r file

    if [ -z "$file" ]; then
      file="index.php"
    fi
  fi

  # Check if vhost and app exists
  vhost_directory="/shared/httpd/$vhost"
  app_directory="$vhost_directory/$app"

  if [ "$file" != "index.php" ]; then
    # Make sure the .devilbox folder exists
    mkdir "$vhost_directory/.devilbox" 2>/dev/null

    yml_example=$(get_vhost_gen_yml vhost)
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

function get_vhost_gen_yml() {
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

# Stop function execution
function stop_function() {
  kill -INT $$
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
    echo_error "The directory does not exist!"
  fi
}

###
### Add my own Intro
###

name=$(git config --global user.name || echo "stranger")

quotes=("Let's do this! 🔥" "Let's make money! 💸" "You matter, okay? 😉" "I know you can do it! 😊")
quote=${quotes[$RANDOM % ${#quotes[@]}]}
quote_len=${#quote}

welcome="Welcome, $name! "
welcome_len=${#welcome}

left_pad=$((45-(quote_len+welcome_len)/2))

printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && style "$welcome$(style "$quote" blue)\n" bold green
echo
echo "                    | Available GUIs   | URL                          |"
echo "                    |------------------|------------------------------|"
echo "                    | 🐖 Mailhog       | http://localhost:8025        |"
echo "                    | 📦 Minio (S3)    | http://localhost:8900        |"
echo "                    | 🌐 Ngrok         | http://localhost:4040        |"
echo
echo "------------------------------------------------------------------------------------------"
