# User Documentation

This guide will show you how to use and manage the Inception project.

## Services Provided
- **Wordpress**: The main website, available in your browser.
- **MariaDB**: The database that stores the website's data.
- **NGINX**: The web server that handles the HTTPS connections.
- **Adminer** (Bonus): A web panel to manage the database easily.
- **Static Website** (Bonus): A simple static portfolio page.
- **Redis Cache** (Bonus): Object caching to make WordPress faster.
- **FTP Server** (Bonus): Secure file transfer for WordPress files.
- **Portainer** (Bonus): A web dashboard to see your Docker containers and logs.

## Starting and Stopping the Project
You can control everything using the `Makefile` in the root folder:
- To build and start everything: `make` or `make all`
- To stop the containers safely: `make down`
- To stop and remove containers (but keep the data): `make clean`
- To completely delete containers, images, and empty all the volume data: `make fclean`

## Accessing the Website and Administration Panel
Once you run `make`, you can access the services here:
- WordPress Website: `https://aychikhi.42.fr`
- WordPress Admin Panel: `https://aychikhi.42.fr/wp-admin/`
- Adminer Database Panel: `http://aychikhi.42.fr:8080`
- Static Website: `http://aychikhi.42.fr:8081`
- Portainer Dashboard: `http://aychikhi.42.fr:9000`

**Note**: NGINX uses a self-signed SSL certificate, so your browser will give you a security warning. Just click "Advanced" and proceed to the website. 

> **Important**: Adminer, the Static site, and Portainer run on normal HTTP, so make sure to explicitly type `http://` so your browser doesn't force it to HTTPS.

## Locating and Managing Credentials
We don't hardcode passwords in any of the Dockerfiles. 
- All sensitive passwords (for the database and WordPress admin) need to be stored inside the `secrets/` directory as basic text files.
- When the containers start, they safely read these files once.
- Other normal settings (like usernames or your domain) are configured in the `srcs/.env` file.

## Checking Service Health
If something seems broken:
- Run `make status` to see if all containers are listed as `Up` and `healthy`.
- Run `make logs` to see the output from all containers. If you just want to see logs for one container, you can use `docker logs wordpress` or `docker logs mariadb` to figure out what's wrong.
