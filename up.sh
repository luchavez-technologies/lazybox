#!/bin/sh

# Minio is a S3-compatible object storage service
# ngrok is a cross-platform application that enables developers to expose a local development server to the Internet with minimal effort

# docker-compose up -d httpd mysql redis minio ngrok

# check if no argument is given
if [ $# -eq 0 ]; then
  # ask for user input
  echo "Please enter PHP container (default: php): "
  read input
  # check if input is empty
  if [ -z "$input" ]; then
    # do something if input is empty
    input="php"
  fi

  # store to shell variable
  shell=$input
else
  # store argument to php variable
  input=$@

  # store initial argument to shell variable
  shell=$1
fi

# decide what program to use
if hash docker-compose 2>/dev/null; then
	append="docker-compose"
else
	append="docker compose"
fi

$append up php httpd bind $input -d
$append exec --user devilbox $shell /bin/sh -c "cd /shared/httpd; exec bash -l"
