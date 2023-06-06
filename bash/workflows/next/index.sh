# Create and run a new NextJS app
function next_new() {
  local framework="NextJS"
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

  npx create-next-app@"$framework_version" "$name" 2>/dev/null

  cd "$name" || stop_function

  text_replace "\"next dev\"" "\"next dev --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}

# Clone and run a NextJS app
function next_clone() {
  framework="NextJS"
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

  git clone "$url" "$name" -b "$branch" 2>/dev/null

  port_change "$name" "$port"

  cd "$name" || stop_function

  text_replace "\"next dev\"" "\"next dev --port $port\"" "package.json"

  project_install

  welcome_to_new_app_message "$name"

  project_start
}
