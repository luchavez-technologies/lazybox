# Run own intro
function intro() {
	# Display current workspace
	local workspace=$HOST_PATH_CURRENT_WORKSPACE
	workspace=$(echo "[ 🐳 $workspace workspace ]" | tr '[:lower:]' '[:upper:]')

	local left_pad=$((45 - (${#workspace}) / 2))
	printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && echo_style "$workspace" bold

	# Display name and quote
	local name=$(git_name)

	local quotes=("Let's do this! 🔥" "Let's make money! 💸" "You matter, okay? 😉" "I know you can do it! 😊")
	local quote=${quotes[$RANDOM % ${#quotes[@]}]}
	local quote_len=${#quote}

	local welcome_user="Welcome, $name! "
	local welcome_user_len=${#welcome_user}

	left_pad=$((45 - (quote_len + welcome_user_len) / 2))
	printf '%0.s ' $(seq 1 $left_pad) | tr -d '\n' && echo_style "$welcome_user$(style "$quote" blue)" bold green
	echo
	echo "                  | Webpage            | URL                             |"
	echo "                  |--------------------|---------------------------------|"
	echo "                  | 📊 Dashboard       | https://localhost               |"
	echo "                  | 🌐 Virtual Hosts   | https://localhost/vhosts.php    |"
	echo "                  | ⚙️ C&C             | https://localhost/cnc.php       |"
	#echo "                  | 📝 Workflows Docs  | https://localhost/workflows.php |"
	echo "                  | 🧰 Services        | https://localhost/services.php  |"
	echo
	echo "------------------------------------------------------------------------------------------"
}
