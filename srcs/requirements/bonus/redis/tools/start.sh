#!/bin/bash
set -e

echo ">>> Starting Redis..."

# Start Redis with our config file
# exec makes Redis PID 1
exec redis-server /etc/redis/redis.conf