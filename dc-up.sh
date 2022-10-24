#!/bin/sh

# Minio is a S3-compatible object storage service
# ngrok is a cross-platform application that enables developers to expose a local development server to the Internet with minimal effort

docker-compose up -d httpd mysql redis minio ngrok
