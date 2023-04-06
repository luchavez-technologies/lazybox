alias pa='php artisan'
alias pamfs='pa migrate:fresh --seed'
alias pamfspi='pamfs && pa passport:install'

function laravel_new() {
  laravel_version=""
  php_version=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for project name
    echo "Please enter project name (default: 'app-xxxxxx'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      # do something if input is empty
      name="app-$RANDOM"
    fi

    # ask for Laravel version
    echo "Please enter Laravel version (default: 'latest'):"
    read -r laravel_version

    # ask for Laravel version
    echo "Please enter PHP container to run the app on (default: 'php'):"
    read -r php_version
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      name=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      # do something if input is empty
      laravel_version=$2
    fi

    # check if input is not empty
    if [ -n "$3" ]; then
      # do something if input is empty
      php_version=$3
    fi
  fi

  version=""
  if [ -n "$laravel_version" ]; then
    version=":^$laravel_version"
    # check if the version contains a period
    if [[ ! "$laravel_version" =~ . ]]; then
      version+=".0"
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || exit

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || exit

  # create new laravel app based on the inputs
  composer create-project laravel/laravel$version "$name"

  laravel_link "$name" "$name"
  php_change "$name" "$php_version"

  # cd to project
  cd "$name" || exit
}

function git_clone() {
  php_version=""
  url=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for Git URL
    echo "Please enter Git URL:"
    read -r url
    # check if input is empty
    if [ -z "$url" ]; then
      # do something if input is empty
      exit
    fi

    # ask for project name
    echo "Please enter project name (default: 'app-xxxxxx'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      # do something if input is empty
      name="app-$RANDOM"
    fi

    # ask for Laravel version
    echo "Please enter PHP container where the app should run (default: 'php'):"
    read -r php_version
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      url=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      # do something if input is empty
      name=$2
    fi

    # check if input is not empty
    if [ -n "$3" ]; then
      # do something if input is empty
      php_version=$3
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || exit

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || exit

  # create new laravel app based on the inputs
  git clone "$url" "$name"

  laravel_link "$name" "$name"
  php_change "$name" "$php_version"

  # cd to project
  cd "$name" || exit
}

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function laravel_link() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo "The vhost is empty."
      exit
    fi

    echo "Please enter laravel app name (default: '$vhost'):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      vhost=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      # do something if input is empty
      app=$2
    else
      app=$1
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || exit

  directory="$vhost/$app/public"
  if [ -d "$directory" ]; then
    # cd to vhost
    cd "$vhost" || exit

    # symlink public folder of the new laravel app to htdocs
    ln -s "$app/public" htdocs 2>/dev/null
  fi
}

# This will change the PHP container where the vhost will run on
function php_change() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo "The vhost is empty."
      exit
    fi

    echo "Please enter PHP container where the app should run:"
    read -r php_version

    if [ -z "$php_version" ]; then
      echo "The container name is empty."
      exit
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
    vhost=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
    # do something if input is empty
    php_version=$2
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || exit

  if [ -d "$vhost" ]; then
    # change directory
    cd "$vhost" || exit

    # copy .devilbox/backend.cfg
    if [ -n "$php_version" ]; then
      # do something if input is empty
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:phpfpm:tcp:$php_version:9000" > .devilbox/backend.cfg
      echo "WARNING: The PHP version change won't take effect immediately."
      echo "TODO: Go to C&C page then click 'Reload' on 'watcherd' daemon."
    fi
  fi
}

# This will change back the PHP version of a vhost to the default one by remove the `backend.cfg` file
function php_default() {
  # check if no argument is given
  if [ $# -eq 0 ]; then
    echo "Please enter vhost:"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo "The vhost is empty."
      exit
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
    vhost=$1
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || exit

  if [ -d "$vhost" ]; then
    # change directory
    cd "$vhost" || exit

    # remove .devilbox folder
    rm -rf .devilbox
    echo "WARNING: The PHP version change won't take effect immediately."
    echo "TODO: Go to C&C page then click 'Reload' on 'watcherd' daemon."
  fi
}
