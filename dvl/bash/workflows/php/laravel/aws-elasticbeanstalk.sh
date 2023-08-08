# Publish AWS EB configs
function laravel_aws_eb_publish() {
	local vhost
	local app
	local app_path
	local aws_eb_path
	local folder
	local destination

	vhost=$(ask_vhost_name "$1")
	app=$(ask_app_name "Laravel" "$2" "$vhost")

	app_path="/shared/httpd/$vhost/$app"
	aws_eb_path="/etc/bashrc-devilbox.d/files/php/laravel/aws-elasticbeanstalk"

	shopt -s dotglob
	for dir in "$aws_eb_path"/*; do
		folder=${dir#$aws_eb_path/}
		destination="$app_path/$folder"

		if [ -d "$destination" ]; then
		    echo_error "The $(style " $folder " bold bg-white) folder already exists!"
		else
			execute "cp -rf $dir $destination"
		fi
	done
}
