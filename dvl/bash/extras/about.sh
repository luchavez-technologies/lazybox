# Display MySQL details
function about_devilbox() {
	local password_protected=false
	local ui_enabled=false

	if [ "$DEVILBOX_UI_PROTECT" -eq 1 ]; then
		password_protected=true
	fi

	if [ "$DEVILBOX_UI_ENABLE" -eq 1 ]; then
		ui_enabled=true
	fi

	echo_style "================================== 😈 DEVILBOX SETTINGS ==================================" bold green
	echo "👉 TLD Suffix     : $(style "$TLD_SUFFIX" bold green)"
	echo "👉 UI URL         : $(style "http://localhost" bold green)"
	echo "👉 UI Enabled     : $(style "$ui_enabled" bold green)"
	echo "👉 UI Protected   : $(style "$password_protected" bold green)"
	echo "👉 Username       : $(style "devilbox" bold green)"
	echo "👉 Password       : $(style "$DEVILBOX_UI_PASSWORD" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_php() {
	echo_style "====================================== 🐘 ABOUT PHP ======================================" bold green
	echo "👉 Current Version    : $(style "$PHP_VERSION" bold green)"
	echo "👉 Server Version     : $(style "$PHP_SERVER" bold green)"
	echo "👉 Disabled Modules   : $(style "$PHP_MODULES_DISABLE" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_mysql() {
	url="mysql.${TLD_SUFFIX}"
	echo_style "================================== 💾 MYSQL CREDENTIALS ==================================" bold green
	echo "👉 Status   : $(echo_test_service mysql)"
	echo "👉 URL      : $(style "https://$url" bold green)"
	echo "👉 Username : $(style "root" bold green)"
	echo "👉 Password : $(style "$MYSQL_ROOT_PASSWORD" bold green)"
	echo "👉 Port     : $(style "$HOST_PORT_MYSQL" bold green)"
	echo "👉 Version  : $(style "$MYSQL_SERVER" bold green)"
	echo
	echo "ℹ️ To connect, run this: $(style "mysql -h mysql -u root -P $HOST_PORT_MYSQL -p $MYSQL_ROOT_PASSWORD" bold green)"
	echo "ℹ️ Or, run this: $(style "mysql -h $url -u root -P $HOST_PORT_MYSQL -p $MYSQL_ROOT_PASSWORD" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_redis() {
	echo_style "================================== ☁️ REDIS CREDENTIALS ==================================" bold green
	echo "👉 Status  : $(echo_test_service redis)"
	echo "👉 URL     : $(style "https://redis.${TLD_SUFFIX}" bold green)"
	echo "👉 Port    : $(style "6379" bold green)"
	echo "👉 Args    : $(style "$REDIS_ARGS" bold green)"
	echo "👉 Version : $(style "$REDIS_SERVER" bold green)"
	echo
	echo "ℹ️ To test connection, run this: $(style "redis-cli -h redis -p 6379 ping" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_minio() {
	echo_style "================================== 🪣 MINIO CREDENTIALS ==================================" bold green
	echo "👉 Status     : $(echo_test_service minio)"
	echo "👉 UI URL     : $(style "https://minio.${TLD_SUFFIX}" bold green)"
	echo "👉 UI Port    : $(style "$HOST_PORT_MINIO_CONSOLE" bold green)"
	echo "👉 API URL    : $(style "https://api.minio.${TLD_SUFFIX}" bold green)"
	echo "👉 API Port   : $(style "$HOST_PORT_MINIO" bold green)"
	echo "👉 Username   : $(style "$MINIO_USERNAME" bold green)"
	echo "👉 Password   : $(style "$MINIO_PASSWORD" bold green)"
	echo "👉 Version    : $(style "$MINIO_SERVER" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_ngrok() {
	local vhost=""

	if [ -n "$NGROK_VHOST" ]; then
		vhost="https://$NGROK_VHOST.${TLD_SUFFIX}"
	fi

	echo_style "================================== 🌏 NGROK CREDENTIALS ==================================" bold green
	echo "👉 Status     : $(echo_test_service ngrok)"
	echo "👉 UI URL     : $(style "https://ngrok.${TLD_SUFFIX}" bold green)"
	echo "👉 UI Port    : $(style "$HOST_PORT_NGROK" bold green)"
	echo "👉 VHost      : $(style "$vhost" bold green)"
	echo "👉 Token      : $(style "$NGROK_AUTHTOKEN" bold green)"
	echo "👉 Region     : $(style "$NGROK_REGION" bold green)"
	echo "👉 Version    : $(style "$NGROK_SERVER" bold green)"
	echo_style "==========================================================================================" bold green
}

# Display MySQL details
function about_mailhog() {
	echo_style "================================= 🐷 MAILHOG CREDENTIALS =================================" bold green
	echo "👉 Status     : $(echo_test_service mailhog)"
	echo "👉 UI URL     : $(style "https://mailhog.${TLD_SUFFIX}" bold green)"
	echo "👉 UI Port    : $(style "$HOST_PORT_MAILHOG_CONSOLE" bold green)"
	echo "👉 API Port   : $(style "$HOST_PORT_MAILHOG" bold green)"
	echo "👉 Version    : $(style "$MAILHOG_SERVER" bold green)"
	echo_style "==========================================================================================" bold green
}
