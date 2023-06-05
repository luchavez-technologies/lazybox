alias yii='php yii'

# Create and run a new Yii app
function yii_new() {
  local framework="Yii"
  local php_version

  name=$(ask_app_name "$framework" "" "$1")

  php_version=$(ask_php_version "$3")

  ensure_current_php_container "$php_version"

  cd /shared/httpd || stop_function

  style "🤝 Now creating your awesome $framework app! 🔥🔥🔥\n" bold green

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
  yii migrate 2>/dev/null

  welcome_to_new_app_message "$name"
}

# Clone and run a Yii app
function yii_clone() {
  local framework="Yii"
  local url=""
  local branch="develop"
  local php_version

  url=$(ask_git_url "$framework" "$1")

  branch=$(ask_branch_name "$2")

  name=$(ask_app_name "$framework" "" "$3")

  php_version=$(ask_php_version "$4")

  ensure_current_php_container "$php_version"

  cd /shared/httpd || stop_function

  style "🤝 Now cloning your awesome $framework app! 🔥🔥🔥\n" bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  # symlink and add devilbox config
  symlink "$name" "$name"
  if [ -n "$php_version" ]; then
    php_change "$name" "$php_version"
  else
    php_default "$name"
  fi

  cd "$name" || stop_function
  git checkout "$branch" 2>/dev/null

  yii_replace_env_variables "$name"
  yii migrate

  # install dependencies
  project_install

  welcome_to_new_app_message "$name"
}

# Replace all necessary env variables
function yii_replace_env_variables() {
  local framework="Yii"
  local name
  local snake_name

  name=$(ask_app_name "$framework" "" "$1")

  snake_name=${name//-/_}

  ###
  ### DATABASE VARIABLES
  ###
  local file="config/db.php"

  # This is for DB_PASSWORD
  password=$MYSQL_ROOT_PASSWORD
  text_replace "'password' => ''" "'password' => '$password'" "$file"

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
