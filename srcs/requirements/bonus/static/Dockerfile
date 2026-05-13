FROM debian:bookworm

# Install NGINX to serve the static files
RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy our HTML site into the web root
COPY tools/index.html /var/www/static/index.html

# Copy our NGINX config for the static site
COPY conf/static.conf /etc/nginx/sites-available/default

# Copy startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# Serve on port 80
EXPOSE 80

CMD ["/start.sh"]