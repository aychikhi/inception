# Inception

*This project has been created as part of the 42 curriculum by aychikhi.*

## Description
Inception is a system administration project about Docker and docker-compose. The goal of this project is to build a small infrastructure from scratch using Docker, without pulling any ready-made images. It runs on a Virtual Machine and sets up a WordPress site with PHP-FPM, a MariaDB database, and an NGINX web server over HTTPS (using TLSv1.2 or TLSv1.3). I also added some bonus services.

## Instructions
1. Make sure your `/etc/hosts` file points `aychikhi.42.fr` to `127.0.0.1` or your local IP.
2. The `Makefile` will automatically create the folders for the volumes in `/home/aychikhi/data`.
3. Create your `.env` file in the `srcs` folder and make sure you put your `credentials.txt`, `db_password.txt`, and `db_root_password.txt` inside the `secrets/` directory.
4. Run `make` in the root of the project to build and start everything.
5. Open your browser and go to `https://aychikhi.42.fr` to see the site. Since the SSL certificate is self-signed, you will need to accept the browser warning to proceed.

## Resources
- [Docker Official Docs](https://docs.docker.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/documentation/)
- [WordPress Support](https://wordpress.org/support/)
- I didn't use any AI tools to write the code or documentation for this project.

## Project description

### Virtual Machines vs Docker
Virtual Machines install a complete Operating System (guest OS) on top of the host, which makes them heavy and slow to start. Docker, on the other hand, uses containers that share the host kernel. This means Docker containers are much lighter, take up less space, and start almost instantly.

### Secrets vs Environment Variables
You can pass passwords using environment variables, but anyone who inspects the container can see them easily. Docker secrets are much safer because they mount the sensitive data as files in memory (like `/run/secrets/`), so they aren't exposed in the container's environment setup.

### Docker Network vs Host Network
Using the host network means the container uses the machine's actual network directly, which isn't very secure. By creating a custom Docker network, we create a private bridge. The containers can talk to each other inside this network using their names (like `mariadb:3306`), and the outside world can't access them unless we expose specific ports (like 443 for NGINX).

### Docker Volumes vs Bind Mounts
Bind mounts link an exact folder on the host to a folder in the container, which depends heavily on the host OS. Docker named volumes are managed directly by Docker. For this project, we are required to use named volumes, but we used the local driver to specify exactly where the data is stored (`/home/login/data/`) to fulfill the subject rules.
