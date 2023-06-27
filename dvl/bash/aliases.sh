# Source files
function source_sh_files() {
  file_or_dir="$1"
  if [ -n "$file_or_dir" ]; then
    if [ -d "$file_or_dir" ]; then
      # loop thru the contents
      for item in "$file_or_dir"/*; do
        source_sh_files "$item"
      done
    else
      # source the sh file
      source "$file_or_dir"
    fi
  fi
}

# Source sh files from extras
source_sh_files "/etc/bashrc-devilbox.d/extras"

# Source sh files from workflows
source_sh_files "/etc/bashrc-devilbox.d/workflows"

# Install project dependencies
function project_install() {
  npm_yarn_install
  composer_install
}

# Get user's name from Git config
function git_name() {
  git config --global user.name || echo "stranger"
}

# Invoke intro
intro

# Own some directories
own_directory /var/cache
own_directory /var/log
own_directory /var/lib

# Own NVM automatically by devilbox user
own_nvm

# The loaded ".env" file cannot be edited using "sed" function.
# It was found out that overriding the contents via "cat" function works.
# Therefore, we just save a copy of ".env" to "/tmp" then override the original's contents.
own_file /.env

# Symlink the available services
symlink_services
