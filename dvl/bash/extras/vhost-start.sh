# Start a project
function vhost_start() {
	local vhost

	vhost=$(ask_vhost_name "$1")

	cd "/shared/httpd/$vhost" || stop_function

	if [ -f "start.sh" ]; then
	    ./start.sh
	fi
}
