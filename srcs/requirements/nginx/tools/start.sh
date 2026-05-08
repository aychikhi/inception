#!/bin/bash

# Exit immediately if any command fails
set -e

echo ">>> Generating TLS certificate..."

# Generate a self-signed certificate
# -x509	: output a self-signed certificate (not a request)
# -nodes : don't encrypt the private key (no passphrase needed)
# -days 365 : valid for 1 year
# -newkey rsa:2048 : generate a new 2048-bit RSA key
# -keyout : where to save the private key
# -out : where to save the certificate
# -subj :certificate subject (avoids interactive prompts)
openssl req x509 -nodes -days 365
	-newkey rsa:2048
	-keyout /etc/ssl/private/nginx.key
	-out /etc/ssl/certs/nginx.crt
	-subj "/C=MA/ST=Casablanca/L=Casablanca/0-42/CN=${DOMAIN_NAME}"

echo ">>> TLS certificate generated successfully"
echo ">>> Starting NGINX..."

# exec replaces this shell process with nginx
# This makes nginx PID 1 (required for proper signal handling)
# daemon off = run in forground (required for Docker)
exec nginx -g "daemon off;"

