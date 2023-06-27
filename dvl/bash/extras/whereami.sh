# Where am I?
function whereami() {
  local default="/shared/httpd"
  local absolute
  local workspace_dir=$HOST_PATH_HTTPD_DATADIR
  local workspace=$HOST_PATH_CURRENT_WORKSPACE
  local relative="not found"
  local vhost=""

  absolute=$(pwd)

  if echo "$absolute" | grep -q "^$default"; then
      vhost=${absolute#$default}
      relative="$workspace_dir/$vhost"
      vhost=${vhost#/}
      vhost=${vhost%%/*}
  fi

  echo "👋 Hi, there, $(git_name)! 😉"
  echo
  echo "👉 You are currently inside the $(style "$workspace" bold underline green) workspace."
  echo "👉 Your current IP address is $(style "$(ip_address)" bold underline green) a.k.a. the $(style "$(php_version)" bold underline green) container."
  echo "👉 Your current directory $(style "inside" bold green) the container is $(style "$absolute" bold underline green)"
  echo "👉 Your current directory $(style "outside" bold green) the container is $(style "$relative" bold underline green)"

  if [ -n "$vhost" ]; then
    echo
    echo_style "👉 You are in the vhost called $(style "$vhost" bold underline blue)" green
    echo_style "👉 You can visit your app using this link: $(style "https://$vhost.$TLD_SUFFIX" bold underline blue)" green
  elif [ "$relative" == "not found" ]; then
    echo
    echo_style "🤔 Seems like you got lost. Go back to vhosts directory by running this command: $(style "cd /shared/httpd" bold underline green)" yellow italic
  fi
}
