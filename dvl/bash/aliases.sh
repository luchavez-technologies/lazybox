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

# Wait for HTTPD to be available
echo_curl_httpd
