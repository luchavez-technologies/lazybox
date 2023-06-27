# Execute a string
function execute() {
	local command

	if [ -n "$1" ]; then
		command=$1
	else
		command=$(ask "Please enter $(style "command" underline bold)")

		if [ -z "$command" ]; then
			stop_function
		fi
	fi

	echo_ongoing "Executing command: $(style "$command" bold)"

	if eval "$command"; then
		echo_finished "Executed command: $(style "$command" bold)"
	else
		echo_error "Failed to execute command: $(style "$command" bold)"
	fi
}
