#!bin/bash

# Exit immediately if any command fails
set -e

echo ">>> starting MariaDB set..."

# Make sure runtime directories exist
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# --- Read passwords from Docker secrets ---
# Docker secrets are mounted as files at /run/secrets/
# We read them into variables
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo ">>> Secrets loaded successfully"

# --- Check if this is the first time running ---
# /var/lib/mysql is created during initialization
# If if doesn't exits, we need to initialize the database
if [ ! -d "/var/lib/mysql/wordpress" ]; then
	echo ">>> First run detected - initializing database..."

	# Create required runtime directories
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
	chown -R mysql:mysql /var/lib/mysql

	# Initialize the MariaDB data directory
	# This creates the system tables MariaDB needs
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	echo ">>> Database directory initialized"

	# Generate the initialization script securely with environment variables
	cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

	# Start MariaDB temporarily in the backgroud
	# --bootstrap mode processes SQL without networking
	# We use this to run our initialization SQL
	mysqld --user=mysql --bootstrap < /tmp/init.sql

	echo ">>> Database initialized successfully"
	echo ">>> Database: wordpress"
	echo ">>> User: wpuser created"
else
	echo ">>> Existring database found - skipping initialization"
fi

echo ">>> Starting MariaDB server..."

# Start MariaDB in the forground as PID 1
# --user=mysql			: run as mysql user (not root)
# --console				: log to stdout (good for Docker logs)
# --skip-networking=0		: enable networking (allow remote connections)
exec mysqld --user=mysql --console --skip-networking=0