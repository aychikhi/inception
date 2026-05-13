FROM debian:bookworm

# Install Redis server
RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Copy our custom Redis config
COPY conf/redis.conf /etc/redis/redis.conf

# Copy startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# Redis default port
EXPOSE 6379

CMD ["/start.sh"]