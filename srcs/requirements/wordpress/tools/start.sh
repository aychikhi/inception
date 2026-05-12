#!/bin/bash

# Exit immediately if any command fails
set -e

echo ">>> WordPress container starting..."

# ============================================================
# STEP 1: Read secrets and environment variables
# ============================================================

# Read database password from Docker secret file
DB_PASSWORD=$(cat /run/secrets/db_password)

# Read WordPress admin password from credentials secret
WP_ADMIN_PASS=$(cat /run/secrets/credentials)

# These come from the .env file via docker-compose environment:
# DOMAIN_NAME, MYSQL_DATABASE, MYSQL_USER
# WP_ADMIN_USER, WP_ADMIN_EMAIL, WP_USER, WP_USER_EMAIL

echo ">>> Secrets loaded"

# ============================================================
# STEP 2: Wait for MariaDB to be ready
# ============================================================
# WordPress can't set up without a working database connection
# MariaDB might take a few seconds to start
# We loop until it responds

echo ">>> Waiting for MariaDB to be ready..."

# mysqladmin ping sends a test connection to MariaDB
# -h mariadb   = connect to the 'mariadb' container (Docker DNS)
# -u wpuser    = use the wpuser account
# --silent     = don't print anything
# We try every 2 seconds until it works

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    echo ">>> MariaDB not ready yet - waiting 2 seconds..."
    sleep 2
done

echo ">>> MariaDB is ready!"

# ============================================================
# STEP 3: Set up WordPress files if not already done
# ============================================================

# WordPress files live at /var/www/wordpress (our volume mount point)
# wp-login.php existing means WordPress is already downloaded

if [ ! -f "/var/www/wordpress/wp-login.php" ]; then
    echo ">>> WordPress not found - downloading and configuring..."

    # Create directory if needed and set permissions
    mkdir -p /var/www/wordpress
    chown -R www-data:www-data /var/www/wordpress
    chmod -R 755 /var/www/wordpress

    # --- Download WordPress core files ---
    # wp-cli is installed at /usr/local/bin/wp
    # --allow-root = allow running as root (we're in a container)
    # --path       = where to put WordPress files
    wp core download \
        --allow-root \
        --path=/var/www/wordpress

    echo ">>> WordPress downloaded"

    # --- Create wp-config.php ---
    # This is WordPress's main config file
    # It tells WordPress how to connect to the database
    wp config create \
        --allow-root \
        --path=/var/www/wordpress \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --dbcharset="utf8mb4"

    echo ">>> wp-config.php created"

    # --- Install WordPress ---
    # This creates all the database tables WordPress needs
    # and sets up the admin account
    wp core install \
        --allow-root \
        --path=/var/www/wordpress \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    echo ">>> WordPress installed"
    echo ">>> Admin user: ${WP_ADMIN_USER}"

    # --- Create a second regular user ---
    # Subject requires two users - one admin (above) and one regular user
    # We generate a random password for the regular user
    WP_USER_PASS=$(openssl rand -base64 12)

    wp user create \
        --allow-root \
        --path=/var/www/wordpress \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASS}"

    echo ">>> Regular user created: ${WP_USER}"
    echo ">>> Regular user password: ${WP_USER_PASS}"

    # Set correct permissions on all WordPress files
    chown -R www-data:www-data /var/www/wordpress
    find /var/www/wordpress -type d -exec chmod 755 {} \;
    find /var/www/wordpress -type f -exec chmod 644 {} \;

    echo ">>> WordPress setup complete!"

else
    echo ">>> WordPress already configured - skipping setup"
fi

# ============================================================
# STEP 4: Start PHP-FPM
# ============================================================

echo ">>> Starting PHP-FPM..."

# php-fpm8.2 -F = run in foreground (required for Docker)
# This becomes PID 1 thanks to exec
exec php-fpm8.2 -F