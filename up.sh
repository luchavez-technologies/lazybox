#!/bin/sh

# Minio is a S3-compatible object storage service
# ngrok is a cross-platform application that enables developers to expose a local development server to the Internet with minimal effort

# docker-compose up -d httpd mysql redis minio ngrok

shell=""
if [ $# -eq 0 ]; then
  echo "Please enter PHP container (default: php):"
  read -r input

  if [ -z "$input" ]; then
    input="php"
  fi

  shell=$input
else
  # store all argument to php variable
  input=$*

  # store initial argument to shell variable
  shell=$1
fi

# make sure shell variable starts with php
if echo "$shell" | grep -qv "^php"; then
  shell="php"
fi

# decide what program to use
if hash docker-compose 2>/dev/null; then
	prepend="docker-compose"
else
	prepend="docker compose"
fi

$prepend up php httpd bind $input -d
$prepend exec --user devilbox $shell /bin/sh -c "cd /shared/httpd; exec bash -l"
