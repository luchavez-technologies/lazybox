# Ask for framework name
function ask_framework_name() {
  local framework

  if [ -n "$1" ]; then
    framework=$1
  else
    read -rp "👀 Please enter $(style "framework name" underline bold) ➡️ " framework

    if [ -z "$framework" ]; then
      stop_function
    fi
  fi

  return "$framework"
  return 0
}

# Ask for framework version
function ask_framework_version() {
  local framework
  local default_version=""
  local framework_version=""

  framework=$(ask_framework_name "$1")

  if [ -n "$2" ]; then
    default_version=$2
  else
    read -rp "👀 Please enter $framework $(style "default version" underline bold)) ➡️ " default_version
  fi

  if [ -n "$3" ]; then
    framework_version=$3
  else
    read -rp "👀 Please enter $framework $(style "version" underline bold) (default: $(style "latest" bold blue)) ➡️ " framework_version
  fi

  if [ -n "$framework_version" ]; then
    framework_version="$default_version"
  fi

  echo "$framework_version"
  return 0
}

# Ask for app name
function ask_app_name() {
  local framework
  local default_name
  local default_name_value
  local name

  framework=$(ask_framework_name "$1")

  if [ -n "$2" ]; then
    default_name="$2"
  else
    default_name="app-$RANDOM"
  fi

  if [ -n "$3" ]; then
    name=$3
  else
    read -rp "👀 Please enter $framework $(style "app name" underline bold) (default: $(style "$default_name" bold blue)) ➡️ " name
  fi

  name=$(clean_name "$name")

  if [ -z "$name" ]; then
    name="$default_name"
  fi

  echo "$name"
  return 0
}

# Ask for VHost name
function ask_vhost_name() {
  local vhost

  if [ -n "$1" ]; then
    vhost=$1
  else
    read -rp "👀 Please enter $(style "vhost name" underline bold)) ➡️ " vhost
  fi

  vhost=$(clean_name "$vhost")

  if [ -z "$vhost" ]; then
    echo_error "The vhost name is empty!"
    return 1
  fi

  if [ -d "/shared/httpd/$vhost" ]; then
    echo_error "The vhost name does not exist!"
    return 1
  fi

  echo "$vhost"
  return 0
}

# Ask for Git URL
function ask_git_url() {
  local framework
  local url

  framework=$(ask_framework_name "$1")

  if [ -n "$2" ]; then
    url=$2
  else
    read -rp echo "👀 Please enter $(style "Git URL" underline bold) of your $framework app ➡️ " url

    if [ -z "$url" ]; then
      echo_error "You provided an empty Git URL."
      stop_function
    fi
  fi

  echo "$url"
  return 0
}

# Ask for Git branch name
function ask_branch_name() {
  local branch
  local b

  if [ -n "$1" ]; then
    branch=$1
  else
    read -rp "👀 Please enter $(style "branch name" underline bold) to checkout at (default: $(style "develop" bold blue)) ➡️ " b

    if [ -n "$b" ]; then
      branch="$b"
    fi
  fi
}

# Ask PHP version
function ask_php_version() {
  local php_version
  local version

  if [ -n "$1" ] && is_php_container_valid "$1"; then
    php_version=$1
  else
    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    read -rp "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$(php_version)" bold blue)) ➡️ " version

    if [ -n "$version" ]; then
      php_version=$version
    fi
  fi

  if ! is_php_container_valid "$php_version"; then
    php_version=$(php_version)
  fi

  echo "$php_version"
  return 0
}
