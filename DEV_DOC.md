# Developer Documentation

This document explains how the project is set up and built.

## Setting up the Environment
1. **Prerequisites**: You need Docker, Docker Compose, and `make` installed on your machine.
2. **Secrets & Configurations**:
    - Never push your `.env` or password files to GitHub! 
    - Create a `.env` file in the `srcs/` folder for things like `DOMAIN_NAME` and user names.
    - Create a `secrets/` folder at the root of the project with your passwords in `credentials.txt`, `db_password.txt`, and `db_root_password.txt`.
3. **Local Domain**: Edit your `/etc/hosts` file so that `aychikhi.42.fr` points to `127.0.0.1`.

## Building and Launching
Everything is automated through the `Makefile`.
- When you run `make`, it first creates the necessary folders in `/home/aychikhi/data/`.
- Then it runs `docker-compose -f srcs/docker-compose.yml up -d --build`. This tells Docker to build all the images from their `Dockerfile`s and start the containers.
- The containers use `depends_on` in `docker-compose.yml` and loop checks in their startup scripts to make sure they start in the right order (like WordPress waiting for MariaDB to be fully ready before it tries to connect).

## Container & Volume Management Commands
- Check logs: `docker logs <container_name> -f`
- See all volumes: `docker volume ls`
- Wipe everything clean to start over: `make fclean`. This safely brings down the containers with `--volumes` and then uses `sudo rm -rf` on the data directories to ensure the database and files are totally reset.
- Rebuild everything from scratch: `make re`

## Data Storage and Persistence
All important data is kept outside the containers so we don't lose it if a container crashes. We use Docker named volumes with a local driver to enforce saving the data in `/home/aychikhi/data`.
- The database files go to `/home/aychikhi/data/mariadb`.
- The WordPress files go to `/home/aychikhi/data/wordpress`.
- Because we have `restart: always` set, if a container crashes, Docker will automatically restart it. The container just reconnects to the local volume, so no data is ever lost.
