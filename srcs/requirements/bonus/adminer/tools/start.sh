#!/bin/bash
set -e

echo ">>> Setting up Adminer..."

# Create web directory
mkdir -p /var/www/adminer

# Download Adminer (single PHP file)
# This is the official Adminer download
curl -o /var/www/adminer/index.php \
    https://www.adminer.org/latest.php

echo ">>> Adminer downloaded"

# Create a minimal NGINX config to serve Adminer
echo ">>> Starting PHP and NGINX for Adminer..."

# Start PHP-FPM in background first
php-fpm8.2 -D

# Then start NGINX in foreground as PID 1
exec nginx -g "daemon off;"