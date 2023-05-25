#!/bin/sh

###
### Step 1: Declare functions
###

# Style the inputted string
function style() {
  end_code="\033[0m"
  suffix=""

  # set the first argument as the string
  if [ -n "$1" ]; then
    string=$1
  else
    exit
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

  echo "$styles$string$suffix"
}

# Check if the PHP container name input is valid
function is_php_container_valid() {
  if [ -z "$1" ]; then
    return 1
  fi

  input=$1

  containers=('php' 'php54' 'php55' 'php56' 'php70' 'php71' 'php72' 'php73' 'php74' 'php80' 'php81' 'php82')
  for container in "${containers[@]}"
  do
    if [ "$input" == "$container" ]; then
      return 0
    fi
  done

  return 1
}

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
