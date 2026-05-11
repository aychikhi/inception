#!bin/bash

# Exit immediately if any command fails
set -e

echo ">>> starting MariaDB set..."

# --- Read passwords from Docker secrets ---
# Docker secrets are mounted as files at /run/secrets/
# We read them into variables
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo ">>> Secrets loaded successfully"

# --- Check if this is the first time running ---
# /var/lib/mysql is created during initialization
# If if doesn't exits, we need to initialize the database
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo ">>> First run detected - initializing database..."

	# Create required runtime directories
	mkidir -p /run/mysql
	chown -R mysql:mysql /run/mysql
	chown -R mysql:mysql /var/lib/mysql

	# Initialize the MariaDB data directory
	# This creates the system tables MariaDB needs
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	echo ">>> Database directory initialized"

	# Replace the password placeholder in our SQL script
	# with the actual password from secrets 
	sed -i "s/PLACEHOLDER_WP_PASSWORD/${DB_PASSWORD}/g" /init.sql

	# Start MariaDB temporarily in the backgroud
	# --bootstrap mode processes SQL without networking
	# We use this to run our initialization SQL
	mysql --user=mysql --bootstrap < /init.sql

	# Now set the root password
	# we do this separately because it needs special handling
	mysqld --user=mysql --bootstrap << EOF
USE msql;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}'
FLUSH PRIVILEGES;
EOF

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