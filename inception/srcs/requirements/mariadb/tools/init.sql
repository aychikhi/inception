-- This script runs once when MariaDB initializes for the script time

-- Remove anonymos users (security best practice)
DELETE FROM mysql.user WHERE User='';

-- Remove the best database
DROP DATABASE IF EXISTS test;

-- Remove remote root login (root should only connect locally)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create the WordPress database
CREATE DATABASE IF NOT EXISTS wordpress
	CHARACTER SET utf8mb4
	COLLATE utf8mb4_general_ci;

-- Create the WordPress regular user
-- This is the user WordPress uses to read and write data
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'PLACEHOLDER_WP_PASSWORD';

-- Give this user full access to the wordpress database only
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';

-- Aplly all privileges changes
FLUSH PRIVILEGES;