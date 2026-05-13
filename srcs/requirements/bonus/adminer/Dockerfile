FROM debian:bookworm

# Install NGINX + PHP-FPM (Adminer is a PHP app)
RUN apt-get update && apt-get install -y \
    nginx \
    php-fpm \
    php-mysql \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy NGINX config for Adminer
COPY conf/adminer.conf /etc/nginx/sites-available/default

# Copy startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# Adminer runs on port 8080
EXPOSE 8080

CMD ["/start.sh"]