# Check if the PHP container name input is valid
function is_php_container_valid() {
  if [ -z "$1" ]; then
    return 1
  fi

  input=$1

  containers=('php' 'php54' 'php55' 'php56' 'php70' 'php71' 'php72' 'php73' 'php74' 'php80' 'php81' 'php82')
  for container in "${containers[@]}"
  do
    if [ "$input" == "$container" ]; then
      return 0
    fi
  done

  return 1
}
