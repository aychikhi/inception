#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/credentials)

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done

if [ ! -f "/var/www/wordpress/wp-login.php" ]; then
    mkdir -p /var/www/wordpress
    chown -R www-data:www-data /var/www/wordpress
    chmod -R 755 /var/www/wordpress

    wp core download --allow-root --path=/var/www/wordpress

    wp config create \
        --allow-root \
        --path=/var/www/wordpress \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --dbcharset="utf8mb4"

    wp core install \
        --allow-root \
        --path=/var/www/wordpress \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    WP_USER_PASS=$(openssl rand -base64 12)
    wp user create \
        --allow-root \
        --path=/var/www/wordpress \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASS}"

    chown -R www-data:www-data /var/www/wordpress
    find /var/www/wordpress -type d -exec chmod 755 {} \;
    find /var/www/wordpress -type f -exec chmod 644 {} \;

    wp plugin install redis-cache --allow-root --path=/var/www/wordpress --activate
    wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/wordpress
    wp config set WP_REDIS_PORT 6379 --allow-root --path=/var/www/wordpress --raw
    wp redis enable --allow-root --path=/var/www/wordpress
fi

exec php-fpm8.2 -F
