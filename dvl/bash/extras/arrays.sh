# Get unique array from arguments
function array_unique() {
	if [ $# -eq 0 ]; then
		return 1
	fi

	echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' '
	return 0
}
