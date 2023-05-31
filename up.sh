###
### Step 0: Declare functions
###

source bash/extras/style.sh
source bash/extras/text-replace.sh
source bash/workflows/is-php-container-valid.sh

###
### Step 1: Set Git Credentials
###

name=$(git config --global user.name)
email=$(git config --global user.email)

if [ -z "$name" ] || [ -z "$email" ] ; then
  echo_style "🚨 Seems like you haven't fully configured your Git configs yet." red
  echo_style "😉 Let's set it up first. Don't worry since this is just a one-time setup." blue
  echo

  if [ -z "$name" ]; then
    read -rp "👀 Please enter the Git name ➡️ " name

    if [ -z "$name" ]; then
      echo_style "😔 Your name input is a blank. Please try again." red
      exit
    else
      if git config --global user.name "$name"; then
        echo_style "✅  Your name is now set!" green bold
      else
        echo_style "😔 For some reason, I can't set it correctly." red
        echo_style "😔 Please set it yourself if you know how to or look for help. Really sorry." red
        exit
      fi
    fi
  fi

  if [ -z "$email" ]; then
    read -rp "👀 Please enter the Git email ➡️ " email

    if [ -z "$email" ]; then
      echo_style "😔 Your email input is a blank. Please try again." red
      exit
    else
      if git config --global user.email "$email"; then
        echo_style "✅  Your email is now set!" green bold
      else
        echo_style "😔 For some reason, I can't set it correctly." red
        echo_style "😔 Please set it yourself if you know how to or look for help. Really sorry." red
        exit
      fi
    fi
  fi

  echo
  echo_style "🎉 Alright! Your Git config is now le-Git. Git it? 🥁😂🥹" green bold
  echo
fi

###
### Step 2: Choose from workspaces
### Update the HOST_PATH_HTTPD_DATADIR=./data/www
###

env=".env"

default_data_dir="./data/www"
data_dir_variable="HOST_PATH_HTTPD_DATADIR="
data_dir=$(grep "^$data_dir_variable*" "$env")

# Get substring after ./data/www
current_workspace="${data_dir#$data_dir_variable$default_data_dir}"
current_workspace="${current_workspace#/}"
default_workspace="default"

# Set current space as default if empty
if [ -z "$current_workspace" ]; then
  current_workspace="$default_workspace"
fi

# Move non-workspaces to "default" workspace
# Display all workspaces
echo_style "========== 👔 AVAILABLE WORKSPACES ==========" bold green

# Detect all PHP containers from projects folder
for dir in "$default_data_dir"/*; do
  folder="${dir#$default_data_dir/}"
  if [ -d "$dir/htdocs" ] || [ -d "$dir/.devilbox" ]; then
    mkdir "$default_data_dir/$default_workspace" 2>/dev/null
    mv "$dir" "$default_data_dir/$default_workspace/$folder"
  else
    echo "🐳 $(style "$folder" bold green) ($dir)"
  fi
done

# Ask user to choose from available workspaces with the "$current_workspace" as default
echo
read -rp "👀 Please enter the workspace name (default: $(style "$current_workspace" bold green)) ➡️ " chosen_workspace

# Clean the workspace name by changing spaces and underscores to dashes and changing to lowercase
if [ -n "$chosen_workspace" ]; then
  chosen_workspace=$(echo "${chosen_workspace//[_ ]/-}" | tr '[:upper:]' '[:lower:]')
elif [ -n "$current_workspace" ]; then
  chosen_workspace="$current_workspace"
else
  chosen_workspace="$default_workspace"
fi

# Ask wether to create if does not exist yet
if [ ! -d "$default_data_dir/$chosen_workspace" ]; then
  echo
  echo_error "The $(style "$chosen_workspace" bold green) workspace does not exist yet."
  read -rp "👀 Create new workspace? (y/n) ➡️ " choice
  case "$choice" in
    y|Y )
      mkdir "$default_data_dir/$chosen_workspace"
      ;;
    * )
      echo_error "Create new workplace cancelled."
      exit
      ;;
  esac
fi

# Replace
text_replace "^$data_dir" "$data_dir_variable$default_data_dir/$chosen_workspace" "$env"

###
### Step 3: Prepare containers to boot up
###

declare -a args_php_containers args_non_php_containers detected_php_containers non_php_containers

required_non_php_containers=("httpd" "bind" "mysql" "redis" "minio" "ngrok" "mailhog" "soketi")
required_php_containers=("php")

# Count the number of PHP containers from arguments
# If the count is equal to 1, save the PHP container to "shell" variable
# If not, just empty the "shell" variable

count=0
shell=""
for arg in "$@" ; do
  if is_php_container_valid "$arg"; then
    count=$((count+1))
    if [ $count -eq 1 ]; then
      shell="$arg"
    fi
    args_php_containers+=("$arg")
  else
    args_non_php_containers+=("$arg")
  fi
done

args_php_containers=( $(echo "${args_php_containers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )
args_non_php_containers=( $(echo "${args_non_php_containers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

count=${#args_php_containers[@]}

if [ -n "$shell" ] && [ "$count" -gt 1 ]; then
  shell=""
fi

# Get projects folder from $env
data_dir=$(grep "^HOST_PATH_HTTPD_DATADIR=" "$env")
data_dir=${data_dir#*=}

# Detect all PHP containers from projects folder
for dir in "$data_dir"/*; do
  file="$dir/.devilbox/backend.cfg"
  if [ -f "$file" ]; then
    container=$(grep -m 1 -o ':php[0-9]*:' "$file" | sed 's/^.//;s/.$//')
    detected_php_containers+=("$container")
  fi
done

detected_php_containers=( $(echo "${detected_php_containers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

# Merge the required, args, and detected PHP containers
php_containers=("${required_php_containers[@]}" "${args_php_containers[@]}" "${detected_php_containers[@]}")
php_containers=( $(echo "${php_containers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

# Merge the required and args non-PHP containers
non_php_containers=("${required_non_php_containers[@]}" "${args_non_php_containers[@]}")
non_php_containers=( $(echo "${non_php_containers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

# Merge all containers to boot up
boot_containers=("${non_php_containers[@]}" "${php_containers[@]}")

echo "📝 Args PHP containers                        : $(style "${args_php_containers[*]}" bold green)"
echo "📝 Args Non-PHP containers                    : $(style "${args_non_php_containers[*]}" bold green)"
echo "🔒 Required PHP containers                    : $(style "${required_php_containers[*]}" bold green)"
echo "🔒 Required Non-PHP containers                : $(style "${required_non_php_containers[*]}" bold green)"
echo "🔎 Detected PHP containers from your projects : $(style "${detected_php_containers[*]}" bold green)"
echo "🚀 Containers to boot up                      : $(style "${boot_containers[*]}" bold green)"

###
### Step 4: Boot up the containers and enter container terminal
###

# Decide what program to use
if hash docker-compose 2>/dev/null; then
	docker_compose="docker-compose"
else
	docker_compose="docker compose"
fi

###
### Step 4.1 Ngrok Special Case
###

ngrok="ngrok"
ngrok_token_variable="NGROK_AUTHTOKEN="
ngrok_token=$(grep "^$ngrok_token_variable*" "$env")
ngrok_token=${ngrok_token#*=}

if [ -z "$ngrok_token" ]; then
  $docker_compose stop "$ngrok"
  boot_containers=($(echo "${boot_containers[@]/$ngrok}" | tr -s ' '))
fi

if $docker_compose up -d "${boot_containers[@]}"; then
  if [ -z "$shell" ]; then
    shell="php"
    echo "🐘 Available PHP container terminals: $(style "${php_containers[*]}" bold green)"
    read -rp "👀 Please enter the container name (default: $(style "php" bold green)) ➡️ " container

    if [ -n "$container" ] && is_php_container_valid "$container"; then
      shell="$container"
    fi
  fi

  $docker_compose exec --user devilbox "$shell" /bin/sh -c "cd /shared/httpd; exec bash -l"
fi
