FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz \
    | tar -xz -C /opt/

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9443
CMD ["/start.sh"]