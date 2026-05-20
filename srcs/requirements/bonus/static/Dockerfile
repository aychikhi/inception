FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

COPY tools/index.html /var/www/static/index.html
COPY conf/static.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
