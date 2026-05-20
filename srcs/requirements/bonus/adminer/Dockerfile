FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx php-fpm php-mysql curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && \
    curl -L -o /var/www/adminer/index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY conf/adminer.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
