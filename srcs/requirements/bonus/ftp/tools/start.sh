#!/bin/bash
set -e

FTP_PASSWORD=$(cat /run/secrets/credentials)

if ! id -u ftpuser &>/dev/null; then
    useradd -m -d /var/www/wordpress ftpuser
    echo "ftpuser:${FTP_PASSWORD}" | chpasswd
    chown -R ftpuser:ftpuser /var/www/wordpress
fi

mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd/vsftpd.conf
