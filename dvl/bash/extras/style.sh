# Style the inputted string
function style() {
	end_code="\033[0m"
	suffix=""
	string=""

	# set the first argument as the string
	if [ -n "$1" ]; then
		string=$1
	fi

	# loop through the rest of the arguments
	shift

	styles=""
	for arg in "$@"; do
		case $arg in
		# styles
		bold) styles+="\033[1m" ;;
		italic) styles+="\033[3m" ;;
		underline) styles+="\033[4m" ;;
		strike) styles+="\033[9m" ;;
		# colors
		red) styles+="\033[31m" ;;
		green) styles+="\033[32m" ;;
		yellow) styles+="\033[33m" ;;
		blue) styles+="\033[34m" ;;
		purple) styles+="\033[35m" ;;
		cyan) styles+="\033[36m" ;;
		white) styles+="\033[37m" ;;
		# background colors
		bg-black) styles+="\033[40m" ;;
		bg-red) styles+="\033[41m" ;;
		bg-green) styles+="\033[42m" ;;
		bg-yellow) styles+="\033[43m" ;;
		bg-blue) styles+="\033[44m" ;;
		bg-purple) styles+="\033[45m" ;;
		bg-cyan) styles+="\033[46m" ;;
		bg-white) styles+="\033[47m" ;;
		esac
	done

	if [ -n "$styles" ]; then
		suffix="$end_code"
	fi

	# in case the string contains formatted substring, replace all instance of end_code
	string=$(echo "${string}" | awk -v new="$end_code$styles" '{gsub(/\033\[0m/,new)}1')

	printf "$styles$string$suffix"
}

# Display a styled message
function echo_style() {
	echo "$(style "$@")"
}

# Display error message
function echo_error() {
	echo_style " $(style " ERROR " bg-red white bold) $(style "$1" red bold)"
	return 1
}

# Display success message
function echo_success() {
	echo_style " $(style " SUCCESS " bg-green white bold) $(style "$1" green)"
	return 0
}

# Display finished message
function echo_finished() {
	echo " $(style " FINISHED " bg-green white bold) $(style "$1" green)"
	return 0
}

# Display ongoing message
function echo_ongoing() {
	echo " $(style " ONGOING " bg-yellow white bold) $(style "$1" yellow)"
	return 0
}

# Display ongoing message
function echo_warning() {
	echo " $(style " WARNING " bg-yellow white bold) $(style "$1" bold)"
	return 0
}

# Display info message
function echo_info() {
	echo " $(style " INFO " bg-blue white bold) $1"
	return 0
}

# Display note message
function echo_note() {
	echo " $(style " NOTE " bg-blue white bold) $1"
	return 0
}

# Display "message" message
function echo_message() {
	echo " $(style " MESSAGE " bg-green white bold) $(style "$1" bold)"
	return 0
}

# Display todo message
function echo_todo() {
	echo " $(style " TODO " bg-green white bold) $1"
	return 0
}

# Display input
function echo_input() {
    echo " $(style " INPUT " bg-white bold) $1 ➡️  "
    return 0
}

# Welcome user to new app
function welcome_to_new_app_message() {
	if [ -n "$1" ]; then
		echo_message "👋 Welcome to your new app called $(style " $1 " bg-white bold)! Happy coding! 🎉"
		echo_message "🚀 Here's your app URL: $(style "https://$1.dvl.to" underline bold blue)"
	else
		echo_error "The vhost is empty!"
	fi
}

# Reload watcherd message
function reload_watcherd_message() {
	echo_todo "$(style " Reload " bg-white bold) the $(style " watcherd " bg-white bold) daemon at the $(style " Control & Command " bg-white bold) page: $(style "https://localhost/cnc.php" underline bold blue)"
}
