###
### Step 0: Declare functions
###

source dvl/bash/extras/ask.sh
source dvl/bash/extras/strings.sh
source dvl/bash/extras/style.sh
source dvl/bash/extras/execute.sh

###
### Step 2: Choose from workspaces
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
echo " $(style "     💻 AVAILABLE WORKSPACES     " bg-cyan white bold)"
echo

# Display the workspaces
ctr=0
for dir in "$workspace_dir"/*; do
	folder="${dir#$workspace_dir/}"

	# If the directory is a non-workspace, move to the "default" workspace
	if [ -d "$dir/htdocs" ] || [ -d "$dir/.devilbox" ]; then
		mv "$dir" "$workspace_dir/$default_workspace/$folder" 2>/dev/null
	else
		((ctr++))
		echo " $ctr. $(style " $folder " bg-cyan white bold)$(style " $dir ")"
	fi
done

# Ask user to choose from available workspaces with the "$current_workspace" as default
echo
inputted_workspace=$(ask "Please enter the workspace name to delete")
echo

# Clean the workspace name by changing spaces and underscores to hyphen and changing to lowercase
if [ -n "$inputted_workspace" ]; then
	inputted_workspace=$(clean_name "$inputted_workspace")
fi

# Throw error if the input is empty
if [ -z "$inputted_workspace" ]; then
	echo_error "Your input is empty. Please try again."
	exit
fi

# Remove the workspace directory and its contents
chosen_workspace="$workspace_dir/$inputted_workspace"
if [ -d "$chosen_workspace" ]; then
	execute "rm -rf $chosen_workspace"
else
	echo_warning "The $(style " $inputted_workspace " bg-white bold) workspace does not exist."
	echo_message "It might have existed before so proceeding with deleting its resources."
fi
echo

# Remove the associated resources of the deleted workspace
declare -a resources=( "backup" "log" "database" "mail" "storage" "meilisearch" )

for resource in "${resources[@]}"; do
	echo_message "Deleting $(style " $resource " bg-white bold) resources..."
	resource_path="$resource/$inputted_workspace"
	if [ -d "$resource_path" ]; then
	    execute "rm -rf $resource_path"
	else
		echo_warning "The $(style " $resource_path " bg-white bold) directory does not exist."
	fi
	echo
done
