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
    root=$(ask "Please enter $(style "web root" underline bold) directory")

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
    index=$(ask "Please enter $(style "entry point" underline bold) file")

    if [ -f "$app_directory/$web_root/$index" ]; then
      file="$index"
      break
    else
      echo_error "The $(style "$index" underline bold) file does not exist!"
    fi
  done

  # Do the symlink
  if ln -s "$app_directory/$web_root" "$vhost_directory/$HTTPD_DOCROOT_DIR" 2>/dev/null; then
    echo_success "Successfully symlinked $(style "$app_directory/$web_root" bold blue) to $(style "$vhost_directory/htdocs" bold blue)."
  else
    echo_error "Failed to symlink $(style "$app_directory/$web_root" bold blue) to $(style "$vhost_directory/htdocs" bold blue)."
  fi

  # Copy nginx yml to vhost if file is not index.php
  cp_backend_web_server_yml "$vhost" "$app" "$web_root" "$file"
  return 0
}
