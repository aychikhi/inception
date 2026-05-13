# Developer Documentation

This document explains to fellow developers how the project is architected and built from scratch. 

## Setting up the Environment
1. **Prerequisites**: You must have Docker, Docker Compose, and `make` installed on a Linux host (or VM). Ensure your user has sudo or Docker-group privileges. 
2. **Secrets & Configurations**:
    - Do not commit your secrets to version control. 
    - Create a `.env` file at the root of `srcs/` containing the required keys (`DOMAIN_NAME`, `MYSQL_DATABASE`, etc.).
    - Create a `secrets/` folder at the root of the project with your `credentials.txt`, `db_password.txt`, and `db_root_password.txt`.
3. **Local Domain**: Ensure you modify `/etc/hosts` to point `aychikhi.42.fr` to `127.0.0.1`.

## Building and Launching
The execution pipeline is heavily automated using the `Makefile` and `docker-compose.yml`. 
- Executing `make` evaluates the `all` tag, creating missing directory structures in `/home/aychikhi/data/`.
- `docker-compose -f srcs/docker-compose.yml up -d --build` takes over, triggering Docker to construct images using the `Dockerfile` definitions.
- Docker reads secrets and injects them under `/run/secrets/` in the respective containers securely.
- Order of execution is controlled primarily by the `depends_on` flag and startup `until` loops (e.g., WordPress waiting specifically for MariaDB's port 3306 response).

## Container & Volume Management Commands
- Check logs iteratively: `docker logs <container_name> -f`
- Investigate active volumes: `docker volume ls`
- Wipe Docker clean: `make fclean` safely executes `docker compose down --volumes` followed by a recursive wipe of the data directories to ensure a completely fresh state.
- Force a complete rebuild: `make re`

## Data Storage and Persistence
All stateful data is kept safely decoupled from the container's volatile layer. 
We rely on Docker named volumes enforced with a local driver strategy targeting explicitly `/home/aychikhi/data`.
- MariaDB datastore binds onto `/home/aychikhi/data/mariadb` and stores exact database binary structures.
- WordPress source files exist permanently mapped to `/home/aychikhi/data/wordpress` via NGINX and WordPress containers.
- If a container crashes, the Orchestrator (Docker Daemon) evaluates the `restart: always` flag and spawns a new instance matching the exact configuration. When re-attaching the volumes, no database integrity or content loss occurs.
