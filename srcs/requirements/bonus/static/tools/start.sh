#!/bin/bash
set -e

echo ">>> Starting static website server..."
exec nginx -g "daemon off;"