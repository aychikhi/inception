*This project has been created as part of the 42 curriculum by aychikhi.*

## Description
Inception is a system administration project that introduces Docker and Docker Compose. The goal is to virtualize a multi-service infrastructure from scratch, using specific rules and no ready-made images. The infrastructure runs on a single Virtual Machine and provides a WordPress website, powered by PHP-FPM, backed by a MariaDB database, and served through an NGINX web server over HTTPS (TLSv1.2/TLSv1.3). It also includes several bonus services.

## Instructions
1. Ensure your host file (`/etc/hosts`) maps `localhost` or `127.0.0.1` to the domain `aychikhi.42.fr`.
2. Create the required directories for the named volumes (the `Makefile` will automatically create them in `/home/aychikhi/data`).
3. Set up your `.env` file in the `srcs` directory and ensure the `secrets/` directory contains `credentials.txt`, `db_password.txt`, and `db_root_password.txt`.
4. Run `make` from the project's root directory. This will build all required images and start the containers.
5. In a browser, navigate to `https://aychikhi.42.fr` to view the WordPress site and `https://aychikhi.42.fr:8080/` to access the Adminer interface. Accept the self-signed certificate.

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Documentation](https://wordpress.org/support/)
- AI was utilized to draft documentation, troubleshoot configuration bugs (e.g., Redis configuration errors, Docker-compose duplicate keys), and verify compliance with the project rules.

## Project description

### Virtual Machines vs Docker
Virtual Machines (VMs) emulate an entire hardware system, including a full guest Operating System, making them heavily isolated but resource-intensive. Docker uses containerization, which abstracts the application layer and shares the host OS kernel. Containers are lightweight, start faster, and use a fraction of the memory compared to VMs.

### Secrets vs Environment Variables
Environment variables are widely used to pass configuration to containers but can be insecure if they contain sensitive data (like passwords), since any process in the container can read them easily from the environment. Docker Secrets mount sensitive data as files in memory (`/run/secrets/`). They are temporarily available, significantly harder to leak, and completely decoupled from environmental scope, adhering to better security standards.

### Docker Network vs Host Network
Running a container on the host network implies it uses the host's networking stack directly without isolation (all ports are mapped identically). In contrast, creating a custom Docker bridge network adds a layer of isolation. Containers can communicate with each other securely using internal DNS resolution (by service name) without exposing their internal traffic to the external host network. Only explicitly published ports (like NGINX's 443) are routed outside.

### Docker Volumes vs Bind Mounts
Bind mounts link a specific path on the host to a path inside the container. They depend on the host machine's directory structure and OS. Docker named volumes are fully managed by Docker and stored in a part of the host filesystem (`/var/lib/docker/volumes/...` typically). However, in this project, we configure a local driver for named volumes targeting a specific `/home/login/data/` path to fulfill both persistence and administrative convenience requirements.
