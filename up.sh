###
### Step 0: Declare functions
###

source dvl/bash/extras/arrays.sh
source dvl/bash/extras/ask.sh
source dvl/bash/extras/execute.sh
source dvl/bash/extras/strings.sh
source dvl/bash/extras/style.sh
source dvl/bash/extras/text-replace.sh
source dvl/bash/workflows/php-version.sh

###
### Step 1: Set Git Credentials
###

name=$(git config --global user.name)
email=$(git config --global user.email)

if [ -z "$name" ] || [ -z "$email" ]; then
	echo_warning "Seems like you haven't fully configured your Git configs yet."
	echo_message "Let's set it up first. Don't worry since this is just a one-time setup."
	echo

	if [ -z "$name" ]; then
		name=$(ask "Please enter the Git name")

		if [ -z "$name" ]; then
			echo_error "Your name input is a blank. Please try again."
			exit
		else
			if git config --global user.name "$name"; then
				echo_success "Your name is now set!"
			else
				echo_error "For some reason, I can't set it correctly."
				echo_error "Please set it yourself if you know how to or look for help. Really sorry."
				exit
			fi
		fi
	fi

	if [ -z "$email" ]; then
		email=$(ask "Please enter the Git email")

		if [ -z "$email" ]; then
			echo_error "Your email input is a blank. Please try again."
			exit
		else
			if git config --global user.email "$email"; then
				echo_success "Your email is now set!"
			else
				echo_error "For some reason, I can't set it correctly."
				echo_error "Please set it yourself if you know how to or look for help. Really sorry."
				exit
			fi
		fi
	fi

	echo_success "Alright! 🎉 Your Git config is now set."
	echo
fi

# Decide what program to use
if hash docker-compose 2>/dev/null; then
	docker_compose="docker-compose"
else
	docker_compose="docker compose"
fi

# Set docker-compose working directory
docker_compose="$docker_compose --project-directory=dvl"

###
### Step 2: Choose from workspaces
###

env="./dvl/.env"

default_data_dir="./dvl/data/www"

workspace_dir_variable="HOST_PATH_WORKSPACE_DIR="
workspace_dir=$(grep "^$workspace_dir_variable*" "$env")
workspace_dir=${workspace_dir#$workspace_dir_variable}

# replace ../ with ./
workspace_dir=${workspace_dir//..\//.\/}

current_workspace_variable="HOST_PATH_CURRENT_WORKSPACE="
current_workspace=$(grep "^$current_workspace_variable*" "$env")
current_workspace_copy="$current_workspace"
current_workspace=${current_workspace#$current_workspace_variable}
default_workspace="default"

# Automatically move all directories from "./dvl/data/www" to the "./workspaces" directory
for dir in "$default_data_dir"/*; do
	folder="${dir#$default_data_dir/}"
	if [ "$dir" != "$default_data_dir/*" ]; then
		mv "$dir" "$workspace_dir/$folder"
	fi
done

# Set current workspace as "default" if empty or if does not exist
if [ -z "$current_workspace" ] || [ ! -d "$workspace_dir/$current_workspace" ]; then
	current_workspace="$default_workspace"
fi

# Create the default workspace if it does not exist yet
if [ ! -d "$workspace_dir/$default_workspace" ]; then
	mkdir "$workspace_dir/$default_workspace"
fi

# Display all workspaces
echo " $(style "     💻 AVAILABLE WORKSPACES     " bg-cyan white bold)"
echo

# Display the workspaces
for dir in "$workspace_dir"/*; do
	folder="${dir#$workspace_dir/}"

	# If the directory is a non-workspace, move to the "default" workspace
	if [ -d "$dir/htdocs" ] || [ -d "$dir/.devilbox" ]; then
		mv "$dir" "$workspace_dir/$default_workspace/$folder" 2>/dev/null
	else
		echo " $(style " $folder " bg-cyan white bold)$(style " $dir ")"
	fi
done

# Ask user to choose from available workspaces with the "$current_workspace" as default
echo
inputted_workspace=$(ask "Please enter the workspace name (default: $(style "$current_workspace" bold green))")

# Clean the workspace name by changing spaces and underscores to hyphen and changing to lowercase
if [ -n "$inputted_workspace" ]; then
	inputted_workspace=$(clean_name "$inputted_workspace")
fi

# Choose a default workspace if the input is empty
if [ -z "$inputted_workspace" ]; then
	if [ -n "$current_workspace" ]; then
		inputted_workspace="$current_workspace"
	else
		inputted_workspace="$default_workspace"
	fi
fi

# Ask whether to create if does not exist yet
chosen_workspace="$workspace_dir/$inputted_workspace"
if [ ! -d "$chosen_workspace" ]; then
	echo
	echo_error "The $(style "$inputted_workspace" bold) workspace does not exist yet."
	choice=$(ask "Create new workspace? (y/n)")
	case "$choice" in
	y | Y)
		mkdir "$chosen_workspace" 2>/dev/null
		;;
	*)
		echo_error "Create new workplace cancelled."
		exit
		;;
	esac
fi

# Replace workspace on the .env file
if [ "$inputted_workspace" != "$current_workspace" ]; then
	text_replace "^$current_workspace_copy" "$current_workspace_variable$inputted_workspace" "$env"
fi

###
### Step 3: Prepare containers to boot up
###

declare -a args_php_containers args_non_php_containers detected_php_containers non_php_containers

required_non_php_containers=("httpd" "bind" "mysql" "redis" "minio" "ngrok" "mailhog")
required_php_containers=("php")

# Count the number of PHP containers from arguments
# If the count is equal to 1, save the PHP container to "shell" variable
# If not, just empty the "shell" variable

count=0
shell=""
for arg in "$@"; do
	if is_php_container_valid "$arg"; then
		count=$((count + 1))
		if [ $count -eq 1 ]; then
			shell="$arg"
		fi
		args_php_containers+=("$arg")
	else
		args_non_php_containers+=("$arg")
	fi
done

read -a args_php_containers <<<"$(array_unique "${args_php_containers[@]}")"
read -a args_non_php_containers <<<"$(array_unique "${args_non_php_containers[@]}")"

count=${#args_php_containers[@]}

if [ -n "$shell" ] && [ "$count" -gt 1 ]; then
	shell=""
fi

# Detect all PHP containers from chosen workspace
for dir in "$chosen_workspace"/*; do
	# Detect PHP container via backend.cfg
	file="$dir/.devilbox/backend.cfg"
	if [ -f "$file" ]; then
		container=$(grep -m 1 -o ':php[0-9]*:' "$file" | sed 's/^.//;s/.$//')
		detected_php_containers+=("$container")
	fi
done

# Get unique detected PHP containers
read -a detected_php_containers <<<"$(array_unique "${detected_php_containers[@]}")"

# Merge the required, args, and detected PHP containers
php_containers=("${required_php_containers[@]}" "${args_php_containers[@]}" "${detected_php_containers[@]}")
read -a php_containers <<<"$(array_unique "${php_containers[@]}")"

# Merge the required and args non-PHP containers
non_php_containers=("${required_non_php_containers[@]}" "${args_non_php_containers[@]}")
read -a non_php_containers <<<"$(array_unique "${non_php_containers[@]}")"

# Merge all containers to boot up
boot_containers=("${non_php_containers[@]}" "${php_containers[@]}")

# Ngrok Special Case
ngrok="ngrok"

ngrok_vhost_variable="NGROK_VHOST="
ngrok_vhost=$(grep "^$ngrok_vhost_variable*" "$env")
ngrok_vhost=${ngrok_vhost#*=}

ngrok_token_variable="NGROK_AUTHTOKEN="
ngrok_token=$(grep "^$ngrok_token_variable*" "$env")
ngrok_token=${ngrok_token#*=}

# Stop Ngrok service if the token is empty or if the vhost is empty or if the vhost does not exist
if [ -z "$ngrok_token" ] || [ -z "$ngrok_vhost" ] || [ ! -d "$chosen_workspace/$ngrok_vhost" ]; then
	$docker_compose stop "$ngrok"
	boot_containers=("$(array_forget ngrok "${boot_containers[@]}")")
fi

echo "📝 Args PHP containers                        : $(style "${args_php_containers[*]}" bold green)"
echo "📝 Args Non-PHP containers                    : $(style "${args_non_php_containers[*]}" bold green)"
echo "🔒 Required PHP containers                    : $(style "${required_php_containers[*]}" bold green)"
echo "🔒 Required Non-PHP containers                : $(style "${required_non_php_containers[*]}" bold green)"
echo "🔎 Detected PHP containers from your projects : $(style "${detected_php_containers[*]}" bold green)"
echo "🚀 Containers to boot up                      : $(style "${boot_containers[*]}" bold green)"

###
### Step 4: Boot up the containers and enter container terminal
###

if execute "$docker_compose up -d ${boot_containers[*]}"; then
	if [ -z "$shell" ]; then
		shell="php"
		echo
		echo_info "Available PHP container terminals: $(style "${php_containers[*]}" bold green)"
		container=$(ask "Please enter the container name (default: $(style "php" bold green))")

		if [ -n "$container" ] && is_php_container_valid "$container"; then
			shell="$container"
		fi
	fi

	$docker_compose exec --user devilbox "$shell" /bin/sh -c "cd /shared/httpd; exec bash -l"
fi
