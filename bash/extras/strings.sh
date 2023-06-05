function clean_name() {
  local name

  if [ -n "$1" ]; then
    name=$1
  else
    read -rp "👀 Please enter $(style "name" underline bold) to clean ➡️ " name
  fi

  if [ -z "$name" ]; then
    echo_error "Inputted name is empty!"
    return 1;
  fi

  echo "${name//[^a-zA-Z0-9\-\.]/-}" | sed 's/^[-.]*//;s/[-.]*$//' | tr '[:upper:]' '[:lower:]' | tr -s '-' '-' | tr -s '.' '.'
  return 0;
}
