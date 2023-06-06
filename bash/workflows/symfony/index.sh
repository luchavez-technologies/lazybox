# Create and run a new Symfony app
function symfony_new() {
  local framework="Symfony"
  local framework_version=""
  local php_version

  name=$(ask_app_name "$framework" "$1")

  framework_version=$(ask_framework_version $framework "$framework_version" "$2")

  php_version_list
  php_version=$(ask_php_version "$3")

  ensure_current_php_container "$php_version"

  if [ -n "$framework_version" ]; then
    # check if the version does not have an asterisk
    if echo "$framework_version" | grep -qv "\*"; then
      framework_version+=".*"
    fi
  fi

  cd /shared/httpd || stop_function

  style "🤝 Now creating your awesome $framework app! 🔥🔥🔥\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  # create project
  composer create-project symfony/framework-standard-edition "$name" "$version"

  # symlink and add devilbox config
  symlink "$name" "$name"
  php_change "$name" "$php_version"

  cd "$name" || stop_function

  welcome_to_new_app_message "$name"
}

# Clone and run a Symfony app
function symfony_clone() {
  local framework="Symfony"
  local url=""
  local branch="develop"
  local php_version

  url=$(ask_git_url "$framework" "$1")

  branch=$(ask_branch_name "$2")

  name=$(ask_app_name "$framework" "$3")

  php_version_list
  php_version=$(ask_php_version "$4")

  ensure_current_php_container "$php_version"

  cd /shared/httpd || stop_function

  style "🤝 Now cloning your awesome $framework app! 🔥🔥🔥\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name" -b "$branch"

  # symlink and add devilbox config
  symlink "$name" "$name"
  php_change "$name" "$php_version"

  cd "$name" || stop_function

  # install dependencies
  config_local_example="app/config/config_local.example.yml"
  config_local="app/config/config_local.yml"

  if [ ! -f "$config_local" ] && [ -f "$config_local_example" ] && cp "$config_local_example" "$config_local"; then
    composer_install
  fi

  welcome_to_new_app_message "$name"
}

# Replace all necessary env variables
function symfony_replace_env_variables() {
  local framework="Symfony"
  local file=".env"
  local name
  local snake_name

  name=$(ask_app_name "$framework" "$1" "$1")

  snake_name=${name//-/_}

  text_replace "^APP_NAME=$framework$" "#APP_NAME=$framework\nAPP_NAME=\"$name\"" "$file"
  text_replace "^APP_URL=http:\/\/localhost$" "#APP_URL=http:\/\/localhost\nAPP_URL=https:\/\/$name.dvl.to" "$file"

  ###
  ### DATABASE VARIABLES
  ###

  # This is for DB_HOST
  text_replace "^DB_HOST=127.0.0.1$" "#DB_HOST=127.0.0.1\nDB_HOST=mysql" "$file"

  # This is for DB_PORT
  text_replace "^DB_PORT=3306$" "#DB_PORT=3306\nDB_PORT=\"\$\{HOST_PORT_MYSQL\}\"" "$file"

  # This is for DB_USERNAME
  text_replace "^DB_USERNAME=homestead$" "#DB_USERNAME=homestead\nDB_USERNAME=root" "$file"

  # This is for DB_PASSWORD
  text_replace "^DB_PASSWORD=secret$" "#DB_PASSWORD=secret\nDB_PASSWORD=\"\$\{MYSQL_ROOT_PASSWORD\}\"" "$file"

  # This is for DB_DATABASE
  if text_replace "^DB_DATABASE=homestead$" "#DB_DATABASE=homestead\nDB_DATABASE=$snake_name" "$file"; then
    password=$MYSQL_ROOT_PASSWORD
    if [ -z "$password" ]; then
      mysql -u root -h mysql -e "create database $snake_name"
    else
      mysql -u root -h mysql -e "create database $snake_name" -p "$password"
    fi
  fi

  # This is for DB_PASSWORD
  text_replace "^DB_PASSWORD=$" "#DB_PASSWORD=\nDB_PASSWORD=\"\$\{MYSQL_ROOT_PASSWORD\}\"" "$file"

  ###
  ### REDIS VARIABLES
  ###

  # This is for REDIS_HOST
  if text_replace "^REDIS_HOST=127.0.0.1$" "#REDIS_HOST=127.0.0.1\nREDIS_HOST=redis" "$file"; then
    # This is for REDIS_PORT
    text_replace "^REDIS_PORT=6379$" "#REDIS_PORT=6379\nREDIS_PORT=\"\$\{HOST_PORT_REDIS\}\"" "$file"

    # This is for SESSION_DRIVER
    text_replace "^SESSION_DRIVER=file$" "#SESSION_DRIVER=file\nSESSION_DRIVER=redis" "$file"

    # This is for QUEUE_CONNECTION
    text_replace "^QUEUE_CONNECTION=sync$" "#QUEUE_CONNECTION=sync\nQUEUE_CONNECTION=redis" "$file"

    # This is for CACHE_DRIVER
    text_replace "^CACHE_DRIVER=file$" "#CACHE_DRIVER=file\nCACHE_DRIVER=redis" "$file"
  fi

  ###
  ### MAILHOG VARIABLES
  ###

  # This is for MAIL_HOST
  text_replace "^MAIL_HOST=smtp.mailtrap.io$" "#MAIL_HOST=smtp.mailtrap.io\nMAIL_HOST=mailhog" "$file"

  # This is for MAIL_PORT
  text_replace "^MAIL_PORT=2525$" "#MAIL_PORT=2525\nMAIL_PORT=\"\$\{HOST_PORT_MAILHOG\}\"" "$file"

  ###
  ### S3 VARIABLES
  ###

  # This is for AWS_ACCESS_KEY_ID
  text_replace "^AWS_ACCESS_KEY_ID=$" "#AWS_ACCESS_KEY_ID=\nAWS_ENDPOINT=\"https:\/\/api.minio.dvl.to\"\nAWS_ACCESS_KEY_ID=\"\$\{MINIO_USERNAME\}\"" "$file"

  # This is for AWS_SECRET_ACCESS_KEY
  text_replace "^AWS_SECRET_ACCESS_KEY=$" "#AWS_SECRET_ACCESS_KEY=\nAWS_SECRET_ACCESS_KEY=\"\$\{MINIO_PASSWORD\}\"" "$file"

  # This is for AWS_BUCKET
  if text_replace "^AWS_BUCKET=$" "#AWS_BUCKET=\nAWS_BUCKET=$name" "$file"; then
    text_replace "^FILESYSTEM_DRIVER=local$" "#FILESYSTEM_DRIVER=local\nFILESYSTEM_DRIVER=s3" "$file"
    text_replace "^FILESYSTEM_DISK=local$" "#FILESYSTEM_DISK=local\nFILESYSTEM_DISK=s3" "$file"
  fi
}
