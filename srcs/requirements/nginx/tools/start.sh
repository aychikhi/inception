#!/bin/bash
set -e

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/CN=${DOMAIN_NAME}" 2>/dev/null

exec nginx -g "daemon off;"
