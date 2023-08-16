# List all of vhosts
function vhosts() {
	local list=""
	local path="/shared/httpd/"

	for vhost in "$path"*; do
		vhost=${vhost#$path}
		vhost="$vhost.$TLD_SUFFIX"
        if [ -n "$list" ]; then
            list="$list $vhost"
		else
			list="$vhost"
        fi
    done

    echo "$list"
}

# List all vhosts to be added to /etc/hosts
function echo_vhosts() {
    local vhosts

    read -a vhosts <<<"$(vhosts)"

    for vhost in "${vhosts[@]}" ; do
        echo "127.0.0.1 $vhost"
    done
}


