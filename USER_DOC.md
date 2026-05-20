# User Documentation

This guide will explain how to interact with the Inception project stack as an end user or system administrator.

## Services Provided
- **Wordpress**: A fully functional content management system available via the browser.
- **MariaDB**: The relational database ensuring WordPress state and content persistency.
- **NGINX**: The single web entrypoint handling incoming HTTPS connections to forward traffic safely.
- **Adminer** (Bonus): A web-based database management interface.
- **Static Website** (Bonus): A showcase portfolio website.
- **Redis Cache** (Bonus): An object cache mechanism to speed up WordPress response times.
- **FTP Server** (Bonus): Provides secure file transfer capabilities for managing WordPress files.
- **Portainer** (Bonus): A visual Docker management dashboard for monitoring containers, volumes, and logs.

## Starting and Stopping the Project
Use the Makefile commands at the root of the project to manage the lifecycle:
- Start all services: Run `make` or `make all`.
- Stop and gracefully shut down containers: Run `make down`.
- Stop and remove the containers, keeping your volume data: Run `make clean`.
- Wipe everything out, including database and website volume data: Run `make fclean`.

## Accessing the Website and Administration Panel
Once running:
- The main WordPress Website is accessible at: `https://aychikhi.42.fr`
- The WordPress Administration Panel is accessible at: `https://aychikhi.42.fr/wp-admin/`
- The Adminer Database Panel is accessible at: `http://aychikhi.42.fr:8080`
- The Static Website is accessible at: `http://aychikhi.42.fr:8081`
- The Portainer Dashboard is accessible at: `http://aychikhi.42.fr:9000`

**Note**: Since NGINX uses a self-signed TLS certificate, your browser will warn you of a security risk when accessing WordPress. Click "Advanced" and choose "Accept the Risk and Continue" to proceed.

> **Important**: Adminer, Static Website, and Portainer use plain HTTP — always open them directly in a new tab by typing the full URL including `http://` to avoid your browser automatically upgrading the connection to HTTPS.

## Locating and Managing Credentials
Credentials are not stored in image layers. Instead, they are securely managed via files:
- All sensitive credentials (passwords for WP, DB, Admin) are kept inside the `secrets/` directory in plain text files.
- During container startup, these files are read by initialization scripts.
- You can manage your environment structure through `srcs/.env` for non-sensitive configurations (like the `DOMAIN_NAME` and usernames).

## Checking Service Health
To ensure all the services are running without crashing or looping:
- Container Status: Run `make status` to list all containers and check if their status is `Up` and `healthy`.
- Service Logs: Run `make logs` to tail the logs of all running containers in real-time, or `docker logs <container_name>` (e.g. `docker logs wordpress`) to verify a specific service.