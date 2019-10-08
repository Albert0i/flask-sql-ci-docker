#
# Import and expose environment variables
#
cnf ?= .env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

#
# Main 
#
.PHONY: help init init-purge

help:
	@echo
	@echo "Usage: make TARGET"
	@echo
	@echo "Flask MySQL CI Docker project automation helper"
	@echo
	@echo "Targets:"
	@echo "	init 		initialize your app code base from the sloria/cookiecutter-flask repo"
	@echo "	init-purge 	clean up generated code"
	@echo "	dev-build 	build the Docker image for development"
	@echo "	dev-up  	start the app in development mode with Docker Compose"
	@echo "	dev-down 	stop the app in development mode with Docker Compose"
	@echo "	dev-ps  	list development containers"
	@echo "	dev-logs 	follow development logs"
	@echo "	prune-all	prune image, container, network, volume and remove migration folder"
	@echo "	test-run 	run the test with Docker Compose"

#
# Generate project codebase form GitHub using cookiecutter
#
init:
	envsubst <docker/init/cookiecutter.template.yml >docker/init/cookiecutter.yml
	docker-compose -f docker/init/docker-compose.yml up -d --build
	docker cp $(CONTAINER_NAME):/root/$(APP_NAME) ./$(APP_NAME)
	docker-compose -f docker/init/docker-compose.yml down
	rm docker/init/cookiecutter.yml
#	docker container rm $(CONTAINER_NAME) 
#	docker image prune -f 

#
# Remove the generated code, use this before re-running the `init` target 
#
init-purge: 
	rm -rf ./$(APP_NAME)
	docker image rm ${DOCKER_USERNAME}/cookiecutter:${APP_VERSION}-initiator

#
# Build the development image
#
dev-build:
	docker-compose -f docker/dev/docker-compose.yml build

#
# Start up development environment
#
dev-up:
	docker-compose -f docker/dev/docker-compose.yml up -d

#
# Bring down development environment
# 
dev-down:
	docker-compose -f docker/dev/docker-compose.yml down

#
# List development conatiners
#
dev-ps:
	docker-compose -f docker/dev/docker-compose.yml ps

#
# Show development logs
#
dev-logs:
	docker-compose -f docker/dev/docker-compose.yml logs -f		

#
# Prune 
#
prune-all:
	docker image prune -f
	docker container prune -f
	docker network prune -f
	docker volume prune -f
	rm -rf ./$(APP_NAME)/migrations

#
# Run tests
#
test-run:
	docker-compose -f docker/dev/docker-compose.yml up -d
	sleep 10
	docker-compose -f docker/dev/docker-compose.yml exec web flask test
	docker-compose -f docker/dev/docker-compose.yml down 

#
# EOF (2019/10/08)
#

