# Ask for port number input
function ask_port() {
  local port

  if [ -n "$1" ]; then
    port=$1
  else
    read -rp "👀 Please enter $(style "port number" underline bold) ➡️ " p

    if [ -n "$p" ]; then
      port=$p
    fi
  fi

  port=$(echo "$port" | grep -o '[0-9]\+')

  if [ -z "$port" ]; then
    ask_port "$port"
  else
    echo "$port"
    return 0
  fi
}

# Check if the port is taken
function port_check() {
  local port=$(ask_port "$1")

  if (echo >/dev/tcp/localhost/"$port") &>/dev/null; then
    return 1;
  else
    return 0;
  fi
}

# Get port suggestion based from inputted initial port
function port_suggest() {
  local port=$(ask_port "$1")

  if port_check "$port"; then
    echo "$port"
    return 0
  else
    ((port++))
    port_suggest "$port"
  fi
}
