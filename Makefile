DOCKER_COMPOSE = docker-compose --file containers/docker-compose.yml
RUN = $(DOCKER_COMPOSE) run --rm

setup:
	$(DOCKER_COMPOSE) build
	$(RUN) web mix setup

clean:
	$(DOCKER_COMPOSE) down --remove-orphans

console:
	$(RUN) --service-ports web iex -S mix phx.server

sh:
	$(RUN) web sh -l

db:
	$(RUN) db-console

# Aliases

c: console

.PHONY: setup clean console sh db c
