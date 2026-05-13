FROM debian:bookworm

# Install vsftpd (Very Secure FTP Daemon)
RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Copy config
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

# Copy startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# FTP command port + passive mode ports
EXPOSE 21 21100-21110

CMD ["/start.sh"]