FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 443

CMD ["/start.sh"]
