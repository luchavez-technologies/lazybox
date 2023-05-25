

# This will replace a text with another text inside a file
function text_replace() {
  strict=1 # not strict
  comment=1 # not comment
  if [ $# -eq 0 ]; then
    echo "👀 Please enter the search text:"
    read -r search

    if [ -z "$search" ]; then
      echo_error "The search text is empty!"
      stop_function
    fi

    echo "👀 Please enter the replace text:"
    read -r replace

    if [ -z "$replace" ]; then
      echo_error "The replace text is empty!"
      stop_function
    fi

    echo "👀 Please enter the file name:"
    read -r file_name

    if [ -z "$file_name" ]; then
      echo_error "The file name is empty!"
      stop_function
    elif [ ! -f "$file_name" ]; then
      echo_error "The file does not exist!"
      stop_function
    fi

  else
    if [ -n "$1" ]; then
      search=$1
    else
      echo_error "The search text is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      replace=$2
    else
      echo_error "The replace text is empty!"
      stop_function
    fi

    if [ -n "$3" ]; then
      if [ -f "$3" ]; then
        file_name=$3
      else
        echo_error "The file does not exist!"
        stop_function
      fi
    else
      echo_error "The file name is empty!"
      stop_function
    fi

    if [ -n "$4" ] && [ "$4" -lt 1 ]; then
      strict=0
    fi
  fi

  if [ "$strict" -eq 0 ]; then
    pattern="^$search$"
  else
    pattern="$search"
  fi

  if [ "$comment" -eq 0 ]; then
    replace="\#$search\n$replace"
  fi

  # check if text actually exists
  if grep -q "$pattern" "$file_name" && sed -i "s/$pattern/$replace/g" "$file_name"; then
    echo_success "Successfully replaced $(style "$search" bold blue) with $(style "$replace" bold blue)."
  fi
}

# This will make a symbolic link that connects the project's "public" folder to vhost's "htdocs"
function symlink() {
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "👀 Please enter PHP $(style "app name" underline bold) (default: $(style "$vhost" bold blue)):"
    read -r app

    if [ -z "$app" ]; then
      app=$vhost
    fi
  else
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      app=$2
    else
      app=$1
    fi
  fi

  cd /shared/httpd || stop_function

  directory="$vhost/$app/public"
  if [ -d "$directory" ]; then
    cd "$vhost" || stop_function

    # symlink public folder of the new laravel app to htdocs
    if ln -s "$app/public" htdocs 2>/dev/null; then
      echo_success "Successfully symlinked $(style "$app/public" bold blue) to $(style "htdocs" bold blue)."
    else
      echo_error "Failed to symlink $(style "$app/public" bold blue) to $(style "htdocs" bold blue)."
    fi
  fi
}

# Display error message
function echo_error() {
  style "🚨 $1" red
  return 1
}

# Display success message
function echo_success() {
  style "✅  $1" green
  return 0
}

# Style the inputted string
function style() {
  end_code="\033[0m"
  suffix=""

  # set the first argument as the string
  if [ -n "$1" ]; then
    string=$1
  else
    stop_function
  fi

  # loop through the rest of the arguments
  shift

  styles=""
  for arg in "$@"
  do
    case $arg in
      # styles
      bold) styles+="\033[1m" ;;
      italic) styles+="\033[3m" ;;
      underline) styles+="\033[4m" ;;
      strike) styles+="\033[9m" ;;
      # colors
      red) styles+="\033[31m" ;;
      green) styles+="\033[32m" ;;
      yellow) styles+="\033[33m" ;;
      blue) styles+="\033[34m" ;;
      purple) styles+="\033[35m" ;;
      cyan) styles+="\033[36m" ;;
      white) styles+="\033[37m" ;;
    esac
  done

  if [ -n "$styles" ]; then
    suffix="$end_code"
  fi

  # in case the string contains formatted substring, replace all instance of end_code
  string=$(echo "${string}" | awk -v new="$end_code$styles" '{gsub(/\033\[0m/,new)}1')

  echo -e "$styles$string$suffix"
}

# Stop function execution
function stop_function() {
  kill -INT $$
}

# Welcome user to new app
function welcome_to_new_app_message() {
  if [ -n "$1" ]; then
    reload_watcherd_message
    style "👋 Welcome to your new app ($(style "$1" bold blue))! Happy coding! 🎉" green
    style "🚀 Here's your app URL: $(style "https://$1.dvl.to" underline bold blue)" green
  else
    echo_error "The vhost is empty!"
  fi
}

# Reload watcherd message
function reload_watcherd_message() {
  style "🔄 Click $(style "Reload" bold blue) on $(style "watcherd" bold blue) daemon on C&C page: $(style "http://localhost/cnc.php" underline bold blue)" green
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
### Step 1: Set Git Credentials
###

name=$(git config --global user.name)
email=$(git config --global user.email)

if [ -z "$name" ] || [ -z "$email" ] ; then
  style "🚨 Seems like you haven't fully configured your Git configs yet." red
  style "😉 Let's set it up first. Don't worry since this is just a one-time setup." blue
  echo

  if [ -z "$name" ]; then
    read -rp "👀 Please enter the Git name ➡️ " name

    if [ -z "$name" ]; then
      style "😔 Your name input is a blank. Please try again." red
      exit
    else
      if git config --global user.name "$name"; then
        style "✅  Your name is now set!" green bold
      else
        style "😔 For some reason, I can't set it correctly." red
        style "😔 Please set it yourself if you know how to or look for help. Really sorry." red
        exit
      fi
    fi
  fi

  if [ -z "$email" ]; then
    read -rp "👀 Please enter the Git email ➡️ " email

    if [ -z "$email" ]; then
      style "😔 Your email input is a blank. Please try again." red
      exit
    else
      if git config --global user.email "$email"; then
        style "✅  Your email is now set!" green bold
      else
        style "😔 For some reason, I can't set it correctly." red
        style "😔 Please set it yourself if you know how to or look for help. Really sorry." red
        exit
      fi
    fi
  fi

  echo
  style "🎉 Alright! Your Git config is now le-Git. Git it? 🥁😂🥹" green bold
  echo
fi

###
### Step 2: Add my own Intro
###

name=$(git config --global user.name || echo "stranger")

quotes=("Let's do this! 🔥" "Let's make money! 💸" "You matter, okay? 😉" "I know you can do it! 😊")
quote=${quotes[$RANDOM % ${#quotes[@]}]}
quote_len=${#quote}

welcome="Welcome, $name! "
welcome_len=${#welcome}

left_pad=$((45-(quote_len+welcome_len)/2))

printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && style "$welcome$(style "$quote" blue)" bold green
echo
echo "                    | Available GUIs   | URL                          |"
echo "                    |------------------|------------------------------|"
echo "                    | 🐖 Mailhog       | http://localhost:8025        |"
echo "                    | 📦 Minio (S3)    | http://localhost:8900        |"
echo "                    | 🌐 Ngrok         | http://localhost:4040        |"
echo
echo "------------------------------------------------------------------------------------------"
