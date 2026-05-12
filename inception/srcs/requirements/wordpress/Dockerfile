# Use Debian 12 Bookworm as base
FROM debian:bookworm

# Install PHP-FPM and all extensions WordPress needs
# php-fpm          : FastCGI Process Manager for PHP
# php-mysql        : lets PHP talk to MariaDB
# php-curl         : HTTP requests (for updates, APIs)
# php-gd           : image processing
# php-mbstring     : multi-byte string handling (needed for non-English)
# php-xml          : XML processing
# php-zip          : zip file handling (plugin/theme installs)
# php-intl         : internationalization
# curl             : to download WP-CLI
# default-mysql-client : for mysqladmin ping command
# openssl          : to generate random user password
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-intl \
    curl \
    default-mysql-client \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (WordPress Command Line Interface)
# This tool lets us configure WordPress from the command line
# instead of clicking through a browser
RUN curl -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Copy our PHP-FPM pool configuration
# This replaces the default www.conf
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Create the directory where WordPress files will live
# This gets mounted as a volume (files persist here)
RUN mkdir -p /var/www/wordpress \
    && chown -R www-data:www-data /var/www/wordpress

# Copy startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# PHP-FPM listens on port 9000
EXPOSE 9000

# Run startup script
CMD ["/start.sh"]