#!/bin/bash
set -e

echo ">>> Setting up FTP server..."

# Read FTP password from secret
FTP_PASSWORD=$(cat /run/secrets/credentials)

# Create FTP user if it doesn't exist
# This user will own the WordPress files
if ! id -u ftpuser &>/dev/null; then
    echo ">>> Creating FTP user..."

    # Create user with home directory at WordPress files
    useradd -m -d /var/www/wordpress ftpuser

    # Set password from secret
    echo "ftpuser:${FTP_PASSWORD}" | chpasswd

    # Give user ownership of WordPress directory
    chown -R ftpuser:ftpuser /var/www/wordpress

    echo ">>> FTP user created"
fi

# Create required vsftpd directory
mkdir -p /var/run/vsftpd/empty

echo ">>> Starting FTP server on port 21..."

# Start vsftpd in foreground as PID 1
exec vsftpd /etc/vsftpd/vsftpd.conf