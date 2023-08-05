# 1. Choose from workspaces (source)
# 2. Choose from vhosts
# 3. Choose from workspaces (target)
# 4. Move vhost from source to destination

###
### Step 0: Declare functions
###

source dvl/bash/extras/ask.sh
source dvl/bash/extras/strings.sh
source dvl/bash/extras/style.sh
source dvl/bash/extras/execute.sh
source dvl/bash/extras/services.sh
source dvl/bash/extras/arrays.sh

###
### Step 1: Choose from workspaces (source)
###

env="./dvl/.env"

workspace_dir_variable="HOST_PATH_WORKSPACE_DIR="
workspace_dir=$(grep "^$workspace_dir_variable*" "$env")
workspace_dir=${workspace_dir#$workspace_dir_variable}

# replace ../ with ./
workspace_dir=${workspace_dir//..\//.\/}

current_workspace_variable="HOST_PATH_CURRENT_WORKSPACE="
current_workspace=$(grep "^$current_workspace_variable*" "$env")
current_workspace=${current_workspace#$current_workspace_variable}
default_workspace="default"

# Display all workspaces
echo " $(style "     💻 SOURCE WORKSPACES     " bg-cyan white bold)"
echo

# Display the workspaces
for dir in "$workspace_dir"/*; do
	folder="${dir#$workspace_dir/}"
	echo " $(style " $folder " bg-cyan white bold)$(style " $dir ")"
done

# Ask user to choose from available workspaces with the "$current_workspace" as default
echo
echo
inputted_src_workspace=$(ask "Please enter the $(style " source " bg-white bold) workspace (default: $(style "$current_workspace" bold green))")

# Clean the workspace name by changing spaces and underscores to hyphen and changing to lowercase
if [ -n "$inputted_src_workspace" ]; then
	inputted_src_workspace=$(clean_name "$inputted_src_workspace")
fi

# Choose a default workspace if the input is empty
if [ -z "$inputted_src_workspace" ]; then
	if [ -n "$current_workspace" ]; then
		inputted_src_workspace="$current_workspace"
	else
		inputted_src_workspace="$default_workspace"
	fi
fi

src_workspace="$workspace_dir/$inputted_src_workspace"

# Throw error if the input does not exist
if [ ! -d "$src_workspace" ]; then
	echo_error "The $(style " $inputted_src_workspace " bg-white bold) workspace does not exist. Please try again."
	exit
fi

###
### Step 2: Choose from vhosts
###

echo
echo " $(style "     💻 AVAILABLE VIRTUAL HOSTS     " bg-cyan white bold)"
echo

read -a services<<<"$(services)"
for dir in "$src_workspace"/*; do
	folder="${dir#$src_workspace/}"

	found=1
	for service in "${services[@]}" ; do
	    if [ "${folder%%$service}" != "$folder" ]; then
	    	found=0
	    	break
	    fi
	done

	if [ $found -eq 1 ]; then
		echo " $(style " $folder " bg-cyan white bold)$(style " $dir ")"
	fi
done

# Ask user to choose from available virtual hosts
echo
inputted_vhost=$(ask "Please enter the vhost to migrate")

# Clean the workspace name by changing spaces and underscores to hyphen and changing to lowercase
if [ -n "$inputted_vhost" ]; then
	inputted_vhost=$(clean_name "$inputted_vhost")
fi

src_vhost="$src_workspace/$inputted_vhost"

# Throw error if the input does not exist
if [ ! -d "$src_vhost" ]; then
	echo_error "The $(style " $inputted_vhost " bg-white bold) virtual host does not exist. Please try again."
	exit
fi

###
### Step 3: Choose from workspaces (destination)
###

# Display all workspaces
echo
echo " $(style "     💻 DESTINATION WORKSPACES     " bg-cyan white bold)"
echo

# Display the workspaces
for dir in "$workspace_dir"/*; do
	folder="${dir#$workspace_dir/}"
	if [ "$folder" != "$inputted_src_workspace" ]; then
		echo " $(style " $folder " bg-cyan white bold)$(style " $dir ")"
	fi
done

# Ask user to choose from available workspaces
echo
inputted_dest_workspace=$(ask "Please enter the $(style " destination " bg-white bold) workspace")

# Clean the workspace name by changing spaces and underscores to hyphen and changing to lowercase
if [ -n "$inputted_dest_workspace" ]; then
	inputted_dest_workspace=$(clean_name "$inputted_dest_workspace")
fi

dest_workspace="$workspace_dir/$inputted_dest_workspace"

# Throw error if the input does not exist
if [ ! -d "$dest_workspace" ]; then
	echo_error "The $(style " $inputted_dest_workspace " bg-white bold) workspace does not exist. Please try again."
	exit
fi

###
###
### Step 4: Move vhost from source to destination

execute "mv $src_vhost $dest_workspace"

# Remove the associated resources of the deleted workspace
# Todo: move backup to another workspace
# Todo: move database data to another workspace
# Todo: move logs to another workspace
# Todo: move storage data to another workspace


#declare -a resources=( "backup" "log" "database")
#
#for resource in "${resources[@]}"; do
#	echo_message "Moving $(style " $resource " bg-white bold) resources..."
#	resource_src_path="$resource/$inputted_src_workspace/$inputted_vhost"
#	resource_dest_path="$resource/$inputted_dest_workspace"
#	if [ -d "$resource_src_path" ]; then
#		if [ -d "$resource_dest_path/$inputted_vhost" ]; then
#			echo_warning "The $(style " $resource_dest_path/$inputted_vhost " bg-white bold) directory already exists."
#		else
#			execute "mv $resource_src_path $resource_dest_path"
#		fi
#	else
#		echo_warning "The $(style " $resource_src_path " bg-white bold) directory does not exist."
#	fi
#	echo
#done
