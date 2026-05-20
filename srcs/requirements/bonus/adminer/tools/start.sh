#!/bin/bash
set -e

php-fpm8.2 -D
exec nginx -g "daemon off;"
