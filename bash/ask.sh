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

  echo "$framework"
  return 0
}

# Ask for framework version
function ask_framework_version() {
  local framework
  local default_version=""
  local default_version_display="latest"
  local framework_version=""

  framework=$(ask_framework_name "$1")

  if [ -n "$2" ]; then
    default_version=$2
    default_version_display=$2
  fi

  if [ -n "$3" ]; then
    framework_version=$3
  else
    read -rp "👀 Please enter $framework $(style "version" underline bold) (default: $(style "$default_version_display" bold blue)) ➡️ " framework_version
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
  local name

  framework=$(ask_framework_name "$1")

  if [ -n "$3" ]; then
    default_name="$3"
  else
    default_name="app-$RANDOM"
  fi

  if [ -n "$2" ]; then
    name=$2
  else
    read -rp "👀 Please enter $framework $(style "app name" underline bold) (default: $(style "$default_name" bold blue)) ➡️ " name
  fi

  if [ -z "$name" ]; then
    name="$default_name"
  fi

  name=$(clean_name "$name")

  # If "$3" is not empty, it means that it's a vhost name. An error should be thrown if the vhost directory does not exist.
  # If "$3" is empty, it means that an app will be created. An error should be thrown if the vhost directory exists.
  if [ -n "$3" ] && [ ! -d "/shared/httpd/$3/$name" ]; then
    echo_error "The app name ($(style $name underline bold)) does not exist!"
    ask_app_name "$1" "" "$3"
  elif [ -z "$3" ] && [ -d "/shared/httpd/$name" ]; then
    echo_error "The vhost name ($(style $name underline bold)) is already taken!"
    ask_app_name "$1" "" "$3"
  else
    echo "$name"
    return 0
  fi

  return 1
}

# Ask for VHost name
function ask_vhost_name() {
  local vhost

  if [ -n "$1" ]; then
    vhost=$1
  else
    read -rp "👀 Please enter $(style "vhost name" underline bold) ➡️ " vhost
  fi

  vhost=$(clean_name "$vhost")

  if [ -z "$vhost" ]; then
    echo_error "The vhost name is empty!"
    ask_vhost_name ""
  elif [ ! -d "/shared/httpd/$vhost" ]; then
    echo_error "The vhost name does not exist!"
    ask_vhost_name ""
  else
    echo "$vhost"
    return 0
  fi

  return 1
}

# Ask for Git URL
function ask_git_url() {
  local framework
  local url

  framework=$(ask_framework_name "$1")

  if [ -n "$2" ]; then
    url=$2
  else
    read -rp "👀 Please enter $(style "Git URL" underline bold) of your $framework app ➡️ " url

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
