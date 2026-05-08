#variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data

# Default target - builds and starts everything
all:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@docker compose -f $(COMPOSE_FILE) up -d --build

# Stop containers (keep data)
down:
	@docker compose -f $(COMPOSE_FILE) down

# Stop + remove containers, images, volumes
clean: down
	@docker compose -f $(COMPOSE_FILE) down --rmi all --volumes
	@rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

# Full rebuild
re: clean all

# Show running containers
status:
	@docker compose -f $(COMPOSE_FILE) ps

# Show logs
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all down clean re status logs
