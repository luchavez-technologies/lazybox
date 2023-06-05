# Create and run a new Vite app
function vite_new() {
  local framework="ViteJS"
  local version="latest"
  local port=5173

  name=$(ask_app_name "$framework" "" "$1")

  framework_version=$(ask_framework_version "$framework" "$framework_version" "$2")

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  echo_style "🚀 Creating your $framework project..." bold green

  mkdir "$name"

  cd "$name" || stop_function

  npx create-vite@"$framework_version" "$name" 2>/dev/null

  port_change "$name" "$port"

  cd "$name" || stop_function

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a Vite app
function vite_clone() {
  framework="ViteJS"
  url=""
  port=5173
  branch="develop"

  branch=$(ask_git_url $framework "$1")

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

  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
