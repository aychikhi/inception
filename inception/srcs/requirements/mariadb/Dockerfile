# Use Debian 12 Bookworm as base
FROM debian:bookworm

# Install MariaDB server
# mariadb-server  : the database server
# Clean apt cache to reduce image size
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*
# Copy our custom MariaDB config
# This overrides the default server config
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy our SQL initialization script
COPY tools/init.sql /init.sql

# Copy and prepare our startup script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

# Create necessary directories and set permissions
# MariaDB needs these directories to exist with correct ownership
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql 
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql \

# MariaDB listens on port 3306
EXPOSE 3306

# Run startup script
CMD ["/start.sh"]