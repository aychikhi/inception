#!/bin/bash
set -e

echo ">>> Starting Portainer..."
exec /opt/portainer/portainer \
    --host=unix:///var/run/docker.sock \
    --sslcert="" \
    --sslkey="" \
    --http-enabled \
    --bind=:9000