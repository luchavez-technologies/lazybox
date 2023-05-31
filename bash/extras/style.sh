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
  for arg in "$@"
  do
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
  echo_style "🚨 $1" red
  return 1
}

# Display success message
function echo_success() {
  echo_style "✅  $1" green
  return 0
}

# Welcome user to new app
function welcome_to_new_app_message() {
  if [ -n "$1" ]; then
    echo_style "👋 Welcome to your new app ($(style "$1" bold blue))! Happy coding! 🎉" green
    echo_style "🚀 Here's your app URL: $(style "https://$1.dvl.to" underline bold blue)" green
  else
    echo_error "The vhost is empty!"
  fi
}

# Reload watcherd message
function reload_watcherd_message() {
  echo_style "🔄 Click $(style "Reload" bold blue) on $(style "watcherd" bold blue) daemon on C&C page: $(style "http://localhost/cnc.php" underline bold blue)" green
}
