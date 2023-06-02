function clean_name() {
  local name

  if [ -n "$1" ]; then
    name=$1
  else
    echo "👀 Please enter $(style "name" underline bold) to clean:"
    read -r name

    if [ -z "$name" ]; then
      echo_error "Inputted name is empty!"
      return 1;
    fi
  fi

  echo "${name//[^a-zA-Z0-9\-]/-}" | sed 's/^-*//;s/-*$//' | tr '[:upper:]' '[:lower:]' | tr -s '-' '-'
  return 0;
}
