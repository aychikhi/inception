FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 21 21100-21110

CMD ["/start.sh"]
