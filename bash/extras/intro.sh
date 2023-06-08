# Run own intro
function intro() {
  # Display current workspace
  local workspace=$HOST_PATH_CURRENT_WORKSPACE
  workspace=$(echo "[ 🐳 $workspace workspace ]" | tr '[:lower:]' '[:upper:]')

  local left_pad=$((45-(${#workspace})/2))
  printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && echo_style "$workspace" bold

  # Display name and quote
  local name=$(git_name)

  local quotes=("Let's do this! 🔥" "Let's make money! 💸" "You matter, okay? 😉" "I know you can do it! 😊")
  local quote=${quotes[$RANDOM % ${#quotes[@]}]}
  local quote_len=${#quote}

  local welcome_user="Welcome, $name! "
  local welcome_user_len=${#welcome_user}

  left_pad=$((45-(quote_len+welcome_user_len)/2))
  printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && echo_style "$welcome_user$(style "$quote" blue)" bold green
  echo
  echo "                    | Services           | URL                        |"
  echo "                    |--------------------|----------------------------|"
  echo "                    | 🐖 Mailhog         | https://mailhog.dvl.to     |"
  echo "                    | 📦 Minio (Console) | https://minio.dvl.to       |"
  echo "                    | 📦 Minio (API)     | https://api.minio.dvl.to   |"
  echo "                    | 🌐 Ngrok           | http://localhost:4040      |"
  echo "                    | 🔈 Soketi          | https://soketi.dvl.to      |"
  echo
  echo "------------------------------------------------------------------------------------------"
}
