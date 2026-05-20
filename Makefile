# Inception Makefile

COMPOSE_FILE    = srcs/docker-compose.yml
DATA_DIR        = /home/aychikhi/data

# MAIN TARGETS

# Default: create data dirs + build + start everything
all: $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@docker compose -f $(COMPOSE_FILE) up -d --build

# Create data directories
$(DATA_DIR)/wordpress:
	@mkdir -p $(DATA_DIR)/wordpress

$(DATA_DIR)/mariadb:
	@mkdir -p $(DATA_DIR)/mariadb

# Stop containers (keep images and volumes)
down:
	@echo ">>> Stopping all services..."
	@docker compose -f $(COMPOSE_FILE) down

# Stop + remove containers and images (keep volumes/data)
clean: down
	@echo ">>> Removing containers and images..."
	@docker compose -f $(COMPOSE_FILE) down --rmi all

# Full clean including volumes and data
fclean: clean
	@echo ">>> Removing all data volumes..."
	@docker compose -f $(COMPOSE_FILE) down --volumes
	@sudo rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@echo ">>> Full clean complete"

# Full rebuild
re: fclean all

# UTILITY TARGETS

# Show container status
status:
	@docker compose -f $(COMPOSE_FILE) ps

# Follow logs from all containers
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

# Follow logs from one service: make log s=nginx
log:
	@docker compose -f $(COMPOSE_FILE) logs -f $(s)

# Open a shell inside a container: make shell s=wordpress
shell:
	@docker compose -f $(COMPOSE_FILE) exec $(s) bash

# Show all Docker images
images:
	@docker images

.PHONY: all down clean fclean re status logs log shell images
