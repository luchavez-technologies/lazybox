alias pa='php artisan'
alias pamfs='pa migrate:fresh --seed'

# Create and run a new Laravel app
function laravel_new() {
  laravel_version=""
  php_version=$(php_version)
  if [ $# -eq 0 ]; then
    echo "👀 Please enter Laravel $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "👀 Please enter Laravel $(style "version" underline bold) (default: $(style "latest" bold blue)):"
    read -r laravel_version

    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$php_version" bold blue)):"
    read -r version

    if [ -n "$version" ] && is_php_container_valid "$version"; then
      php_version=$version
    fi
  else
    if [ -n "$1" ]; then
      name=$1
    fi

    if [ -n "$2" ]; then
      laravel_version=$2
    fi

    if [ -n "$3" ]; then
      php_version=$3
    fi
  fi

  # Validate if "php_version" input matches the current PHP container
  if ! is_php_container_valid "$php_version"; then
    echo_error "Invalid PHP container name: $(style "$php_version" bold)"
    stop_function
  fi

  if ! is_php_container_current "$php_version"; then
    current=$(php_version)
    echo_error "PHP container mismatch! You are currently inside $(style "$current" bold blue) container."
    echo "✋ To switch to $(style "$php_version" bold blue), exit this container first then run $(style "./up.sh $php_version" bold blue)."
    stop_function
  fi

  version=""
  if [ -n "$laravel_version" ]; then
    version=":^$laravel_version"

    # check if the version does not have a period
    if echo "$laravel_version" | grep -qv "\."; then
      version+=".0"
    fi
  fi

  cd /shared/httpd || stop_function

  style "🤝 Now creating your awesome Laravel app! 🔥🔥🔥" bold green

  mkdir "$name"

  cd "$name" || stop_function

  composer create-project "laravel/laravel$version" "$name"

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  cd "$name" || stop_function

  env=".env"
  # run migrate:fresh --seed if .env exists
  if [ -f $env ]; then
    replace_env_variables "$name"
    pa migrate --seed 2>/dev/null
  fi

  welcome_to_new_app_message "$name"
}

# Clone and run a Laravel app
function laravel_clone() {
  url=""
  php_version=$(php_version)
  branch="develop"
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "Git URL" underline bold) of your Laravel app:"
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

    echo "👀 Please enter $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$php_version" bold blue)):"
    read -r version

    if [ -n "$version" ] && is_php_container_valid "$version"; then
      php_version=$version
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
      php_version=$4
    fi
  fi

  cd /shared/httpd || stop_function

  style "🤝 Now cloning your awesome Laravel app! 🔥🔥🔥" bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"
  git checkout "$branch" 2>/dev/null

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  cd "$name" || stop_function

  # copy .env.example to .env
  env=".env"
  env_example=".env.example"
  if [ ! -f $env ] && [ -f $env_example ] ; then
    if cp "$env_example" "$env"; then
      replace_env_variables "$name"
      pa migrate --seed 2>/dev/null
    fi
  fi

  # install dependencies
  project_install

  welcome_to_new_app_message "$name"
}

# Replace APP_NAME and APP_URL on .env with Devilbox's DB URL
function replace_app_name() {
  file=".env"

  if [ -n "$1" ]; then
    text_replace "APP_NAME=Laravel" "APP_NAME=\"$1\"" "$file" 0 0
    text_replace "APP_URL=http:\/\/localhost" "APP_URL=https:\/\/$1.dvl.to" "$file" 0 0
  fi
}

# Replace DB_HOST, DB_PORT, DB_DATABASE, and DB_PASSWORD on .env with Devilbox's DB URL
function replace_db() {
  file=".env"

  # This is for DB_HOST
  text_replace "DB_HOST=127.0.0.1" "DB_HOST=mysql" "$file" 0 0

  # This is for DB_PORT
  text_replace "DB_PORT=3306" "DB_PORT=\"\$\{HOST_PORT_MYSQL\}\"" "$file" 0 0

  # This is for DB_DATABASE
  if [ -n "$1" ]; then
    app=$1
    app=${app//-/_}

    if text_replace "DB_DATABASE=laravel" "DB_DATABASE=$app" "$file"; then 0
      password=$MYSQL_ROOT_PASSWORD
      if [ -z "$password" ]; then
        mysql -u root -h mysql -e "create database $app"
      else
        mysql -u root -h mysql -e "create database $app" -p "$password"
      fi
    fi
  fi

  # This is for DB_PASSWORD
  text_replace "DB_PASSWORD=" "DB_PASSWORD=\"\$\{MYSQL_ROOT_PASSWORD\}\"" "$file" 0 0
}

# Replace REDIS_HOST and REDIS_PORT on .env with Devilbox's DB URL
function replace_redis() {
  file=".env"

  # This is for REDIS_HOST
  text_replace "REDIS_HOST=127.0.0.1" "REDIS_HOST=redis" "$file" 0 0

  # This is for REDIS_PORT
  text_replace "REDIS_PORT=6379" "REDIS_PORT=\"\$\{HOST_PORT_REDIS\}\"" "$file" 0 0

  # This is for SESSION_DRIVER
  text_replace "SESSION_DRIVER=file" "SESSION_DRIVER=redis" "$file" 0 0

  # This is for QUEUE_CONNECTION
  text_replace "QUEUE_CONNECTION=sync" "QUEUE_CONNECTION=redis" "$file" 0 0

  # This is for CACHE_DRIVER
  text_replace "CACHE_DRIVER=file" "CACHE_DRIVER=redis" "$file" 0 0
}

# Replace MAIL_HOST and MAIL_PORT on .env with Devilbox's DB URL
function replace_mailhog() {
  file=".env"

  # This is for MAIL_HOST
  text_replace "MAIL_HOST=mailpit" "MAIL_HOST=mailhog" "$file" 0 0

  # This is for MAIL_PORT
  text_replace "MAIL_PORT=1025" "MAIL_PORT=\"\$\{HOST_PORT_MAILHOG\}\"" "$file" 0 0
}

# Replace AWS_ENDPOINT, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_URL, and AWS_BUCKET on .env with Devilbox's DB URL
function replace_s3_host() {
  file=".env"

  # This is for AWS_ACCESS_KEY_ID
  text_replace "AWS_ACCESS_KEY_ID=" "AWS_ENDPOINT=\"http:\/\/minio:\$\{HOST_PORT_MINIO\}\"\nAWS_ACCESS_KEY_ID=\"\$\{MINIO_USERNAME\}\"" "$file" 0 0

  # This is for AWS_SECRET_ACCESS_KEY
  text_replace "AWS_SECRET_ACCESS_KEY=" "AWS_SECRET_ACCESS_KEY=\"\$\{MINIO_PASSWORD\}\"" "$file" 0 0

  # This is for AWS_BUCKET
  if [ -n "$1" ]; then
    app=$1
    app=${app//-/_}

    if text_replace "AWS_BUCKET=" "AWS_BUCKET=$app\nAWS_URL=\"http:\/\/$1.dvl.to:\$\{HOST_PORT_MINIO\}\/\$\{AWS_BUCKET\}\"" "$file" 0 0; then
      text_replace "FILESYSTEM_DRIVER=local" "FILESYSTEM_DRIVER=s3" "$file" 0 0
      text_replace "FILESYSTEM_DISK=local" "FILESYSTEM_DISK=s3" "$file" 0 0
    fi
  fi
}

# Replace all necessary env variables
# Todo: Detect if APP_KEY is set then set if not
function replace_env_variables() {
  replace_app_name "$@"
  replace_db "$@"
  replace_redis
  replace_mailhog
  replace_s3_host "$@"
}
