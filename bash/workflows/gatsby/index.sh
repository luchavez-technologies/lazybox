# Create and run a new GatsbyJS app
function gatsby_new() {
  local framework="GatsbyJS"
  local framework_version="latest"
  local port=8000

  name=$(ask_app_name "$framework" "$1")

  framework_version=$(ask_framework_version "$framework" "$framework_version" "$2")

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  port_change "$name" "$port"

  echo_style "🚀 Creating your $framework project..." bold green

  npx gatsby@"$framework_version" new "$name" 2>/dev/null

  cd "$name" || stop_function

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a GatsbyJS app
function gatsby_clone() {
  framework="GatsbyJS"
  url=""
  port=8000
  branch="develop"

  url=$(ask_git_url "$framework" "$1")

  branch=$(ask_branch_name "$2")

  name=$(ask_app_name $framework "$3")

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  git clone "$url" "$name"

  port_change "$name" "$port"

  cd "$name" || stop_function
  git checkout "$branch" 2>/dev/null

  text_replace "\"gatsby develop\"" "\"gatsby develop -H 0.0.0.0 --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
