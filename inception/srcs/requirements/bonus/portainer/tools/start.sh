#!/bin/bash
set -e

exec /opt/portainer/portainer \
    --host=unix:///var/run/docker.sock \
    --sslcert="" \
    --sslkey="" \
    --http-enabled \
    --bind=:9000
