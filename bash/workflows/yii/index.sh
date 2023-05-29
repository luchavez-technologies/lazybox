alias yii='php yii'

# Create and run a new Yii app
function yii_new() {
  yii_version=""
  php_version=$(php_version)

  if [ -n "$1" ]; then
    name=$1
  else
    echo "👀 Please enter Yii $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi
  fi

  if [ -n "$2" ]; then
    php_version=$2
  else
    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$php_version" bold blue)):"
    read -r version

    if [ -n "$version" ] && is_php_container_valid "$version"; then
      php_version=$version
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

  cd /shared/httpd || stop_function

  style "🤝 Now creating your awesome Yii app! 🔥🔥🔥\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  # create project
  composer create-project yiisoft/yii2-app-basic "$name"

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  cd "$name" || stop_function

  yii_replace_env_variables "$name"
  yii migrate

  welcome_to_new_app_message "$name"
}

# Clone and run a Yii app
function yii_clone() {
  url=""
  php_version=$(php_version)
  branch="develop"

  if [ -n "$1" ]; then
    url=$1
  else
    echo "👀 Please enter $(style "Git URL" underline bold) of your Yii app:"
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
    echo "👀 Please enter $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi
  fi

  if [ -n "$4" ] && is_php_container_valid "$4"; then
    php_version=$4
  else
    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$php_version" bold blue)):"
    read -r version

    if [ -n "$version" ] && is_php_container_valid "$version"; then
      php_version=$version
    fi
  fi

  cd /shared/httpd || stop_function

  style "🤝 Now cloning your awesome Yii app! 🔥🔥🔥\n" bold green

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

  yii_replace_env_variables "$name"
  yii migrate

  # install dependencies
  project_install

  welcome_to_new_app_message "$name"
}

# Replace all necessary env variables
function yii_replace_env_variables() {
  if [ -n "$1" ]; then
    name=$1
  else
    echo "👀 Please enter Yii $(style "app name" underline bold) (default: $(style "app-random" bold blue)):"
    read -r name

    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi
  fi

  snake_name=${name//-/_}

  ###
  ### DATABASE VARIABLES
  ###

  # This is for DB_PASSWORD
  password=$MYSQL_ROOT_PASSWORD
  text_replace "'password' => ''" "'password' => '$password'" "$file"

  file="config/db.php"
  port=$HOST_PORT_MYSQL

  if text_replace "mysql:host=localhost;dbname=yii2basic" "mysql:host=mysql;dbname=$snake_name;port=$port" "$file"; then
    if [ -z "$password" ]; then
      mysql -u root -h mysql -e "create database $snake_name"
    else
      mysql -u root -h mysql -e "create database $snake_name" -p "$password"
    fi

    return 0
  fi

  return 1
}
