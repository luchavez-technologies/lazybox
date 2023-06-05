# Create and run a new AstroJS app
function astro_new() {
  local framework="AstroJS"
  local framework_version="latest"
  local port=3000

  name=$(ask_app_name "$framework" "$1")

  framework_version=$(ask_framework_version "$framework" "$framework_version" "$2")

  port=$(port_suggest "$port")

  cd /shared/httpd || stop_function

  mkdir "$name"

  cd "$name" || stop_function

  port_change "$name" "$port"

  echo_style "🚀 Creating your $framework project..." bold green

  npx create-astro@"$framework_version" "$name" 2>/dev/null

  cd "$name" || stop_function

  text_replace "\"astro dev\"" "\"astro dev --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a AstroJS app
function astro_clone() {
  framework="AstroJS"
  url=""
  port=3000
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

  text_replace "\"astro dev\"" "\"astro dev --host --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
