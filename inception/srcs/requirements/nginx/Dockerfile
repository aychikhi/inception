# Use Debian 12 (Bookworm) - the penultimate stable version
FROM debian:bookworm

# Install NGINX and OpenSSL
# - nginx      : the web server
# - openssl    : to generate our TLS certificate
# Clean up apt cache to keep image small
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy our NGINX config into the container
# This replaces the default nginx config
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Copy our startup script
COPY tools/start.sh /start.sh

# Make the script executable
RUN chmod +x /start.sh

# Tell Docker this container listens on port 443
# (this is documentation only - actual port mapping is in docker-compose)
EXPOSE 443

# Run our startup script when container starts
# Using CMD (not ENTRYPOINT) for flexibility
CMD ["/start.sh"]