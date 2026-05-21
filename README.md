# 42 Inception

Welcome to my **Inception** repository, a comprehensive system administration and Docker infrastructure project from the 42 curriculum.

## Overview
This project focuses on broadening fundamental knowledge of system administration by deploying a complete web infrastructure using **Docker** and **Docker Compose**. The goal is to virtualize an entire infrastructure from scratch (using Debian or Alpine as base images) inside a Virtual Machine. Pulling ready-made application images (like `nginx:latest` or `wordpress:latest`) is strictly forbidden, meaning every service is built manually via custom Dockerfiles.

The entire architecture runs on a dedicated Docker network and uses Docker volumes for persistent data storage.

## Architecture & Services
The project uses a multi-container Docker Compose setup. It includes a mandatory core web stack, enriched with several bonus administrative and caching services:

### Mandatory Services
1. **NGINX**: The sole entry point for the infrastructure, accepting only secure HTTPS connections (TLSv1.2 or TLSv1.3).
2. **WordPress + PHP-FPM**: The content management system, running isolated from the web server and configured automatically.
3. **MariaDB**: The relational database used to store WordPress user and site data.

### Bonus Services
1. **Redis**: An in-memory data structure store used as an object cache backend for WordPress to increase performance.
2. **FTP Server (vsftpd)**: An FTP service that grants direct access to the WordPress volume for managing files easily.
3. **Adminer**: A lightweight database management interface (in a single PHP file) to visually inspect and manage MariaDB.
4. **Portainer**: A powerful graphical UI to monitor, manage, and inspect the running Docker containers, networks, and volumes.
5. **Static Website**: A standalone, secondary static website built with HTML/CSS/JS, running in its own container to demonstrate routing.

## Project Structure
```text
.
└── inception/
    ├── Makefile             # Automates building, deploying, and cleaning up
    ├── srcs/
    │   ├── docker-compose.yml
    │   ├── .env             # Environment variables for Compose configurations
    │   └── requirements/    # Dockerfiles, configurations, and scripts for all distinct services
    └── secrets/             # Contains initial text configurations (credentials)
```

## Setup & Deployment
To run this project locally:

1. Map the required domain name to localhost in your `/etc/hosts` file:
   ```bash
   127.0.0.1 aychikhi.42.fr
   ```
2. Navigate to the `inception/` directory:
   ```bash
   cd inception
   ```
3. Build and launch the infrastructure using the provided Makefile:
   ```bash
   make
   ```
   *The Makefile will automatically set up the required local data storage directories (e.g., `/home/aychikhi/data/`), build the custom Docker images, and launch the stack in detached mode.*

4. Access the main site in your browser at `https://aychikhi.42.fr`. Since the SSL certificate is self-signed, you will need to accept the browser warning to proceed.
5. To shut down the infrastructure and clean up resources, run:
   ```bash
   make fclean
   ```

*Note: For the shorter 42 subject-specific documentation, see `inception/README.md`.*
