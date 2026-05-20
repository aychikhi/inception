#!/bin/bash
set -e

echo ">>> Starting PHP-FPM..."
php-fpm8.2 -D

echo ">>> Starting NGINX..."
exec nginx -g "daemon off;"