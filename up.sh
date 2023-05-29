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
### Step 2: Prepare containers to boot up
###

declare -a args_php_containers args_non_php_containers detected_php_containers non_php_containers

required_non_php_containers=("httpd" "bind" "mysql" "redis" "minio" "ngrok" "mailhog")
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

# Get projects folder from .env
data_dir=$(grep "^HOST_PATH_HTTPD_DATADIR=" ".env")
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
### Step 3: Boot up the containers and enter container terminal
###

# Decide what program to use
if hash docker-compose 2>/dev/null; then
	prepend="docker-compose"
else
	prepend="docker compose"
fi

if $prepend up "${boot_containers[@]}" -d; then
  if [ -z "$shell" ]; then
    shell="php"
    echo "👽 Available PHP container terminals: $(style "${php_containers[*]}" bold green)"
    read -rp "👀 Please enter the container name (default: $(style "php" bold green)) ➡️ " container

    if [ -n "$container" ] && is_php_container_valid "$container"; then
      shell="$container"
    fi
  fi

  $prepend exec --user devilbox "$shell" /bin/sh -c "cd /shared/httpd; exec bash -l"
fi
