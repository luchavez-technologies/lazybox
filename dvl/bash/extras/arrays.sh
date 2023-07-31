# Get unique array from arguments
function array_unique() {
	if [ $# -eq 0 ]; then
		return 1
	fi

	echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' '
	return 0
}

# Check if an array has a specific element
function array_has() {
    local element

    # The args count must be greater than 1
    if [ $# -gt 1 ]; then
        element=$1
		shift

		for arg in "$@" ; do
			if [ "$arg" == "$element" ]; then
				return 0
			fi
		done
    fi

    return 1
}

# Remove an element from an array
function array_forget() {
    local element
    local arr

	# The args count must be greater than 1
	if [ $# -gt 1 ]; then
		element=$1
		shift
		arr=("$@")

		for i in "${!arr[@]}" ; do
			arg=${arr[i]}
			if [ "$arg" == "$element" ]; then
				unset 'arr[i]'
				echo "${arr[@]}"
				return 0
			fi
		done
	fi

	echo "${arr[@]}"
	return 1
}
