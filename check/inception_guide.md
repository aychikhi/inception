# Inception Project — Complete Guide
> Full conversation guide from VM setup to project completion

---

## Table of Contents

1. [Project Overview & Concepts](#concepts)
2. [Step 1 — VM + Docker Setup](#step-1)
3. [Step 2 — Project Structure](#step-2)
4. [Step 3 — NGINX Container](#step-3)
5. [Step 4 — MariaDB Container](#step-4)
6. [Step 5 — WordPress Container](#step-5)
7. [Step 6 — docker-compose.yml](#step-6)
8. [Step 7 — Testing & Debugging](#step-7)
9. [Step 8 — Bonus Services](#step-8)
10. [Step 9 — Documentation](#step-9)
11. [Workflow Tips](#workflow)

---

## Concepts {#concepts}

### What is Inception?

The goal is to build a small web infrastructure using Docker inside a Virtual Machine. When done, anyone visiting `yourlogin.42.fr` will see a WordPress website running inside containers you built yourself.

```
Your Machine
  └── Virtual Machine (Linux)
        └── Docker
              ├── Container: NGINX     (the door to your website)
              ├── Container: WordPress (the website itself)
              └── Container: MariaDB   (the database)
```

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|---|---|---|
| Size | GBs | MBs |
| Start time | Minutes | Seconds |
| Isolation | Full OS | Just the process |
| Use case | Full environment | Single service |

### Docker Image vs Container

- A **Docker Image** is like a **recipe** — instructions for how to build something
- A **Container** is the **meal** — the actual running result from that recipe

```
Dockerfile → docker build → Image → docker run → Container
```

### Docker Network vs Host Network

- **Host Network** = container shares your computer's network directly ❌ Forbidden in Inception
- **Docker Network** = private isolated network, containers talk by service name ✅ Required

### Docker Volumes vs Bind Mounts

- **Named Volume** = Docker manages the folder, you give it a name ✅ Required
- **Bind Mount** = you manually specify exact host path ❌ Forbidden for main volumes

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| Storage | `/run/secrets/` files | Shell/compose environment |
| Visibility | Only requesting containers | Visible via `docker inspect` |
| Use case | Passwords, API keys | Non-sensitive config |

### Architecture

```
Browser (HTTPS port 443)
        ↓
  [ NGINX Container ]       ← only public entry point, TLS termination
        ↓ FastCGI (port 9000)
  [ WordPress Container ]   ← PHP-FPM, WordPress engine
        ↓ MySQL (port 3306)
  [ MariaDB Container ]     ← database storage
```

### Understanding PID 1

In a container, your main service should be PID 1. Use `exec` at the end of startup scripts:

```bash
exec nginx -g "daemon off;"   # nginx becomes PID 1
```

Without `exec`: shell(PID 1) → nginx(PID 2) ❌
With `exec`: nginx becomes PID 1 ✅

---

## Step 1 — VM + Docker Setup {#step-1}

### Install VirtualBox
Download from https://www.virtualbox.org/wiki/Downloads
- Intel Mac → Intel version
- M1/M2/M3/M4 → ARM version

### Download Debian 12 "Bookworm"
- Current stable = Debian 13 "Trixie"
- **Penultimate stable = Debian 12 "Bookworm"** ✅ use this

Download from: https://www.debian.org/releases/bookworm/debian-installer/

### VM Settings

| Setting | Value |
|---|---|
| RAM | 2048 MB minimum |
| CPU | 2 cores |
| Disk | 20 GB (dynamically allocated) |
| OS | Debian 12 (Bookworm) |

During installation select only:
- ✅ SSH server
- ✅ Standard system utilities

### Post-Installation

```bash
# Add user to sudo
su -
apt install sudo -y
usermod -aG sudo yourlogin
exit

# Test sudo
sudo apt update
```

### SSH Setup (work from Mac terminal)

In VirtualBox: Settings → Network → Adapter 1 → Port Forwarding

| Name | Protocol | Host Port | Guest Port |
|---|---|---|---|
| ssh | TCP | 4242 | 22 |

```bash
# From your Mac
ssh yourlogin@127.0.0.1 -p 4242
```

### Install Docker

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add repo (all on ONE line)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker

# Test
docker run hello-world
```

> ⚠️ The repo add command must be on ONE line — multi-line with backslashes breaks in zsh.

---

## Step 2 — Project Structure {#step-2}

### Domain Setup

```bash
sudo nano /etc/hosts
# Add: 127.0.0.1   yourlogin.42.fr
```

### Create Folder Structure

```bash
mkdir -p ~/inception/srcs/requirements/nginx/{conf,tools}
mkdir -p ~/inception/srcs/requirements/wordpress/{conf,tools}
mkdir -p ~/inception/srcs/requirements/mariadb/{conf,tools}
mkdir -p ~/inception/srcs/requirements/bonus
mkdir -p ~/inception/secrets
mkdir -p ~/data/wordpress ~/data/mariadb

touch ~/inception/Makefile
touch ~/inception/srcs/docker-compose.yml
touch ~/inception/srcs/.env
touch ~/inception/srcs/requirements/nginx/Dockerfile
touch ~/inception/srcs/requirements/wordpress/Dockerfile
touch ~/inception/srcs/requirements/mariadb/Dockerfile
touch ~/inception/README.md
touch ~/inception/USER_DOC.md
touch ~/inception/DEV_DOC.md
```

### Create Secrets

```bash
echo "yourDBpassword"     > ~/inception/secrets/db_password.txt
echo "yourROOTpassword"   > ~/inception/secrets/db_root_password.txt
echo "yourWPpassword"     > ~/inception/secrets/credentials.txt
```

> ⚠️ These files must be in `.gitignore` — NEVER push to Git!

### Create .env

```bash
# Domain
DOMAIN_NAME=yourlogin.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress Admin (NO 'admin' anywhere in username!)
WP_ADMIN_USER=yourlogin_wp
WP_ADMIN_EMAIL=yourlogin@student.42.fr

# WordPress Regular User
WP_USER=yourlogin_user
WP_USER_EMAIL=yourlogin@student.42.fr
```

> ⚠️ `WP_ADMIN_USER` must NOT contain "admin", "Admin", "administrator", or "Administrator" anywhere!

### Makefile

```makefile
COMPOSE_FILE  = srcs/docker-compose.yml
DATA_DIR      = $(HOME)/data

all: $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@echo ">>> Building and starting all services..."
	@docker compose -f $(COMPOSE_FILE) up -d --build

$(DATA_DIR)/wordpress:
	@mkdir -p $(DATA_DIR)/wordpress

$(DATA_DIR)/mariadb:
	@mkdir -p $(DATA_DIR)/mariadb

down:
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@docker compose -f $(COMPOSE_FILE) down --rmi all

fclean: clean
	@docker compose -f $(COMPOSE_FILE) down --volumes
	@sudo rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

re: fclean all

status:
	@docker compose -f $(COMPOSE_FILE) ps

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

log:
	@docker compose -f $(COMPOSE_FILE) logs -f $(s)

shell:
	@docker compose -f $(COMPOSE_FILE) exec $(s) bash

.PHONY: all down clean fclean re status logs log shell
```

> ⚠️ Makefile indentation must use TAB not spaces!

---

## Step 3 — NGINX Container {#step-3}

### nginx.conf

`srcs/requirements/nginx/conf/nginx.conf`

```nginx
server {
    listen      443 ssl;
    listen      [::]:443 ssl;

    server_name  yourlogin.42.fr;

    ssl_certificate     /etc/ssl/certs/nginx.crt;
    ssl_certificate_key /etc/ssl/private/nginx.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    root  /var/www/wordpress;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

### start.sh

`srcs/requirements/nginx/tools/start.sh`

```bash
#!/bin/bash
set -e

echo ">>> Generating TLS certificate..."
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out    /etc/ssl/certs/nginx.crt \
    -subj   "/C=MA/ST=Casablanca/L=Casablanca/O=42/CN=${DOMAIN_NAME}"

echo ">>> Starting NGINX..."
exec nginx -g "daemon off;"
```

### Dockerfile

`srcs/requirements/nginx/Dockerfile`

```dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 443
CMD ["/start.sh"]
```

---

## Step 4 — MariaDB Container {#step-4}

### 50-server.cnf

`srcs/requirements/mariadb/conf/50-server.cnf`

```ini
[mysqld]
user                    = mysql
datadir                 = /var/lib/mysql
bind-address            = 0.0.0.0
port                    = 3306
socket                  = /run/mysqld/mysqld.sock
pid-file                = /run/mysqld/mysqld.pid
character-set-server    = utf8mb4
collation-server        = utf8mb4_general_ci
log_error               = /var/log/mysql/error.log
```

> `bind-address = 0.0.0.0` is required so WordPress container can connect.

### init.sql

`srcs/requirements/mariadb/tools/init.sql`

```sql
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

CREATE DATABASE IF NOT EXISTS wordpress
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'PLACEHOLDER_WP_PASSWORD';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

### start.sh

`srcs/requirements/mariadb/tools/start.sh`

```bash
#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
    chown -R mysql:mysql /var/lib/mysql

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    sed -i "s/PLACEHOLDER_WP_PASSWORD/${DB_PASSWORD}/g" /init.sql
    mysqld --user=mysql --bootstrap < /init.sql

    mysqld --user=mysql --bootstrap << EOF
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld --user=mysql --console --skip-networking=0
```

### Dockerfile

`srcs/requirements/mariadb/Dockerfile`

```dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sql /init.sql
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

EXPOSE 3306
CMD ["/start.sh"]
```

---

## Step 5 — WordPress Container {#step-5}

### www.conf

`srcs/requirements/wordpress/conf/www.conf`

```ini
[www]
user  = www-data
group = www-data
listen = 0.0.0.0:9000
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
```

> `clear_env = no` is critical — lets PHP read Docker environment variables.

### start.sh

`srcs/requirements/wordpress/tools/start.sh`

```bash
#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/credentials)

echo ">>> Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done

if [ ! -f "/var/www/wordpress/wp-login.php" ]; then
    mkdir -p /var/www/wordpress
    chown -R www-data:www-data /var/www/wordpress

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

    # Install Redis cache plugin
    wp plugin install redis-cache --allow-root --path=/var/www/wordpress --activate
    wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/wordpress
    wp config set WP_REDIS_PORT 6379 --allow-root --path=/var/www/wordpress --raw
    wp redis enable --allow-root --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress
fi

exec php-fpm8.2 -F
```

### Dockerfile

`srcs/requirements/wordpress/Dockerfile`

```dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-intl \
    curl \
    default-mysql-client \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9000
CMD ["/start.sh"]
```

---

## Step 6 — docker-compose.yml {#step-6}

`srcs/docker-compose.yml`

```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
  credentials:
    file: ../secrets/credentials.txt

volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/wordpress

  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb

networks:
  inception:
    driver: bridge

services:

  mariadb:
    build:
      context: requirements/mariadb
      dockerfile: Dockerfile
    container_name: mariadb
    image: mariadb
    restart: always
    volumes:
      - mariadb:/var/lib/mysql
    secrets:
      - db_password
      - db_root_password
    environment:
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
    networks:
      - inception
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "--silent"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  wordpress:
    build:
      context: requirements/wordpress
      dockerfile: Dockerfile
    container_name: wordpress
    image: wordpress
    restart: always
    volumes:
      - wordpress:/var/www/wordpress
    secrets:
      - db_password
      - credentials
    environment:
      - DOMAIN_NAME=${DOMAIN_NAME}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - WP_ADMIN_USER=${WP_ADMIN_USER}
      - WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
      - WP_USER=${WP_USER}
      - WP_USER_EMAIL=${WP_USER_EMAIL}
    networks:
      - inception
    depends_on:
      mariadb:
        condition: service_healthy

  nginx:
    build:
      context: requirements/nginx
      dockerfile: Dockerfile
    container_name: nginx
    image: nginx
    restart: always
    volumes:
      - wordpress:/var/www/wordpress
    environment:
      - DOMAIN_NAME=${DOMAIN_NAME}
    networks:
      - inception
    depends_on:
      - wordpress
    ports:
      - "443:443"
```

---

## Step 7 — Testing & Debugging {#step-7}

### Launch

```bash
cd ~/inception
make
```

### Validation Checklist

```bash
# All containers running
make status

# Website responds
curl -k https://yourlogin.42.fr | head -20

# TLS 1.2 works
curl -k --tlsv1.2 https://yourlogin.42.fr -o /dev/null -w "%{http_code}"

# TLS 1.3 works
curl -k --tlsv1.3 https://yourlogin.42.fr -o /dev/null -w "%{http_code}"

# Old TLS rejected (must fail!)
curl -k --tlsv1.0 --tls-max 1.0 https://yourlogin.42.fr

# Two WordPress users exist
docker exec -it mariadb mysql -u root -p -e \
  "USE wordpress; SELECT user_login FROM wp_users;"

# Data in volumes
ls ~/data/mariadb/
ls ~/data/wordpress/wp-config.php

# Containers restart after crash
docker kill wordpress && sleep 5 && make status
```

### Common Problems

| Problem | Cause | Fix |
|---|---|---|
| Container exits immediately | Startup script crashed | Add `set -x` to script |
| WordPress stuck waiting for MariaDB | DB not starting | Check `docker logs mariadb` |
| 502 Bad Gateway | NGINX can't reach WordPress | Check `docker logs wordpress` |
| Permission denied | Wrong file ownership | `chown -R www-data:www-data /var/www/wordpress` |
| Port 443 in use | Another process using it | `sudo ss -tlnp \| grep 443` |

### Full Reset

```bash
make fclean
docker system prune -af --volumes
make
```

---

## Step 8 — Bonus Services {#step-8}

### Folder Structure

```bash
mkdir -p ~/inception/srcs/requirements/bonus/redis/{conf,tools}
mkdir -p ~/inception/srcs/requirements/bonus/ftp/{conf,tools}
mkdir -p ~/inception/srcs/requirements/bonus/static/{conf,tools}
mkdir -p ~/inception/srcs/requirements/bonus/adminer/{conf,tools}
```

### Redis

**redis.conf:**
```ini
bind 0.0.0.0
port 6379
daemonize no
maxmemory 256mb
maxmemory-policy allkeys-lru
```

**Dockerfile:**
```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/*
COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 6379
CMD ["/start.sh"]
```

**start.sh:**
```bash
#!/bin/bash
exec redis-server /etc/redis/redis.conf
```

### FTP (vsftpd)

**vsftpd.conf:**
```ini
local_enable=YES
write_enable=YES
anonymous_enable=NO
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
local_root=/var/www/wordpress
```

**Dockerfile:**
```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y vsftpd && rm -rf /var/lib/apt/lists/*
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 21 21100-21110
CMD ["/start.sh"]
```

### Static Website

**Dockerfile:**
```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*
COPY tools/index.html /var/www/static/index.html
COPY conf/static.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 80
CMD ["/start.sh"]
```

### Adminer

**Dockerfile:**
```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx php-fpm php-mysql curl && rm -rf /var/lib/apt/lists/*
COPY conf/adminer.conf /etc/nginx/sites-available/default
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 8080
CMD ["/start.sh"]
```

### Add to docker-compose.yml

```yaml
  redis:
    build:
      context: requirements/bonus/redis
    container_name: redis
    image: redis
    restart: always
    networks:
      - inception

  ftp:
    build:
      context: requirements/bonus/ftp
    container_name: ftp
    image: ftp
    restart: always
    volumes:
      - wordpress:/var/www/wordpress
    secrets:
      - credentials
    ports:
      - "21:21"
      - "21100-21110:21100-21110"
    networks:
      - inception

  static:
    build:
      context: requirements/bonus/static
    container_name: static
    image: static
    restart: always
    ports:
      - "8081:80"
    networks:
      - inception

  adminer:
    build:
      context: requirements/bonus/adminer
    container_name: adminer
    image: adminer
    restart: always
    ports:
      - "8080:8080"
    networks:
      - inception
    depends_on:
      - mariadb
```

### Bonus Service URLs

| Service | URL |
|---|---|
| Adminer | `http://yourlogin.42.fr:8080` |
| Static site | `http://yourlogin.42.fr:8081` |
| FTP | `ftp://yourlogin.42.fr:21` (user: ftpuser) |

---

## Step 9 — Documentation {#step-9}

### Required Files

- `README.md` — project overview, concepts, setup, AI usage
- `USER_DOC.md` — how to start/stop, access services, credentials
- `DEV_DOC.md` — full setup from scratch, commands, debugging

### README.md Must Include

- First line italicized: `*This project has been created as part of the 42 curriculum by yourlogin.*`
- Description section
- Instructions section
- Resources section with AI usage description
- Project description with comparisons:
  - VMs vs Docker
  - Secrets vs Environment Variables
  - Docker Network vs Host Network
  - Docker Volumes vs Bind Mounts

### .gitignore

```gitignore
secrets/
srcs/.env
.DS_Store
*.swp
.vscode/
```

---

## Workflow Tips {#workflow}

### Laptop → GitHub → School VM Workflow

```
Ubuntu Laptop → git push → GitHub → git clone → School VM
```

**On your laptop:**
```bash
git init
# Create .gitignore FIRST
git add .
git commit -m "feat: inception project"
git push
```

**On school VM after cloning:**
```bash
# Recreate secrets (never in Git!)
mkdir -p secrets
echo "yourpassword"     > secrets/db_password.txt
echo "yourrootpassword" > secrets/db_root_password.txt
echo "yourwppassword"   > secrets/credentials.txt

# Recreate .env
nano srcs/.env

# Add domain
echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts

# Run
make
```

### Create .env.example for reference

```bash
cat > srcs/.env.example << 'EOF'
DOMAIN_NAME=yourlogin.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN_USER=yourlogin_wp
WP_ADMIN_EMAIL=yourlogin@student.42.fr
WP_USER=yourlogin
WP_USER_EMAIL=yourlogin@student.42.fr
EOF
```

### Important Rules Summary

| Rule | Status |
|---|---|
| `network: host` forbidden | ❌ Never use |
| `--link` forbidden | ❌ Never use |
| Bind mounts for main volumes | ❌ Never use |
| Passwords in Dockerfiles | ❌ Never hardcode |
| `latest` tag forbidden | ❌ Use `debian:bookworm` |
| `tail -f` / `sleep infinity` | ❌ Never use |
| Only port 443 exposed (NGINX) | ✅ Required |
| `restart: always` | ✅ Required |
| TLSv1.2 or TLSv1.3 only | ✅ Required |
| Two WordPress users | ✅ Required |
| Admin username without "admin" | ✅ Required |
| Named volumes | ✅ Required |
| One Dockerfile per service | ✅ Required |

### Useful Commands

```bash
# See running containers
docker ps

# Follow logs
docker logs -f wordpress

# Open shell inside container
docker exec -it wordpress bash

# Check resource usage
docker stats

# Full reset
make fclean && make
```

---

---

## Extra Tips & Fixes From the Guide

### Common Mistakes to Avoid

| Mistake | Fix |
|---|---|
| `WP_ADMIN_USER=yourlogin_admin` | ❌ still contains "admin" — use `yourlogin_wp` |
| `MYSQL_PASSWORD_FILE=...` in .env | ❌ remove it — passwords go in secrets files only |
| Typo in domain: `aychikhi0.42.fr` | Run `whoami` to confirm exact login |
| `/etc/hosts` domain doesn't match `.env` | Both must have identical domain name |
| Running `docker build` from wrong folder | Always run from `~/inception` root |
| Pasting `cat > file << 'EOF'` into nano | Run it in terminal, not in a text editor |

---

### Shell Quoting Issue in zsh

Multi-line commands with `\` break in zsh. Always use single line:

```bash
# ❌ Breaks in zsh
echo "deb [arch=$(dpkg --print-architecture)] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee ...

# ✅ Works in zsh
echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

### Docker Permission Denied Fix

```bash
# If you see: permission denied while trying to connect to docker socket
sudo usermod -aG docker $USER
newgrp docker

# If docker not found after new login
export PATH=$PATH:/usr/bin:/usr/local/bin
echo 'export PATH=$PATH:/usr/bin:/usr/local/bin' >> ~/.zshrc
source ~/.zshrc
```

---

### Fix sudo hostname warning

```bash
# If you see: sudo: unable to resolve host yourlogin
echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
```

---

### Dockerfile Formatting Rule

Always use VSCode to edit Dockerfiles — never copy-paste into nano.
The `\` continuation character must be at end of each line:

```dockerfile
# ✅ Correct
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# ❌ Wrong — breaks into separate instructions
RUN apt-get update && apt-get install -y
    nginx
    openssl
    && rm -rf /var/lib/apt/lists/*
```

---

### Portainer Bonus Service

**Dockerfile** (`srcs/requirements/bonus/portainer/Dockerfile`):
```dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz \
    | tar -xz -C /opt/

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9000
CMD ["/start.sh"]
```

**start.sh** (`srcs/requirements/bonus/portainer/tools/start.sh`):
```bash
#!/bin/bash
set -e

echo ">>> Starting Portainer..."
exec /opt/portainer/portainer \
    --host=unix:///var/run/docker.sock \
    --sslcert="" \
    --sslkey="" \
    --http-enabled \
    --bind=:9000
```

**docker-compose.yml entry:**
```yaml
  portainer:
    build:
      context: requirements/bonus/portainer
      dockerfile: Dockerfile
    container_name: portainer
    image: portainer
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    ports:
      - "9000:9000"
    networks:
      - inception
```

Add to volumes section:
```yaml
  portainer_data:
    driver: local
```

Access at: `http://aychikhi.42.fr:9000`

**Defense justification:**
> "I added Portainer because it provides a visual web interface to monitor and manage the entire Docker infrastructure — containers, volumes, networks, and logs — without needing the command line. It's useful for administration and debugging in production environments."

---

### Laptop → GitHub → School VM Workflow

```bash
# On your Ubuntu laptop - work and push
git init
cat > .gitignore << 'EOF'
secrets/
srcs/.env
.DS_Store
*.swp
.vscode/
EOF
git add .
git commit -m "inception project"
git push

# On school VM after cloning
git clone https://github.com/aychikhi/inception.git
cd inception
mkdir -p secrets
echo "yourpassword"     > secrets/db_password.txt
echo "yourrootpassword" > secrets/db_root_password.txt
echo "yourwppassword"   > secrets/credentials.txt
nano srcs/.env          # fill in your values
echo "127.0.0.1 aychikhi.42.fr" | sudo tee -a /etc/hosts
make
```

---

### Final Service URLs

| Service | URL |
|---|---|
| WordPress | `https://aychikhi.42.fr` |
| WordPress Admin | `https://aychikhi.42.fr/wp-admin` |
| Adminer | `http://aychikhi.42.fr:8080` |
| Static site | `http://aychikhi.42.fr:8081` |
| Portainer | `http://aychikhi.42.fr:9000` |
| FTP | `ftp://aychikhi.42.fr:21` (user: ftpuser) |

---

### All 8 Containers Summary

```
✅ mariadb    — database (port 3306 internal)
✅ wordpress  — PHP-FPM + WordPress (port 9000 internal)
✅ nginx      — reverse proxy + TLS (port 443 public)
✅ redis      — object cache (port 6379 internal)
✅ ftp        — file transfer (port 21 public)
✅ static     — portfolio HTML site (port 8081 public)
✅ adminer    — database GUI (port 8080 public)
✅ portainer  — Docker dashboard (port 9000 public)
```

---

*Generated from the Inception project guide conversation*
