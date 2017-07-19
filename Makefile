MEMSIZE=1g
SHMSIZE=1g
NAME=agraph_test
ADMIN_USER=admin
ADMIN_PASSWORD=admin
IMAGE=franzinc/agraph:latest
DATA_IMAGE=agraph-data
DATA_NAME=$(NAME)_data
PORT=10035
SSL_PORT=10036

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:
	@echo "Run this once to create the image with your configuration:"
	@echo ""
	@echo "   make create-data-image"
	@echo ""
	@echo "Run this once to create a new database instance:"
	@echo ""
	@echo "   make create-data"
	@echo "   make create"
	@echo ""
	@echo "To start the database:"
	@echo ""
	@echo "   make start"
	@echo ""
	@echo "To stop the database:"
	@echo ""
	@echo "   make stop"
	@echo ""
	@echo "For local data:"
	@echo ""
	@echo "   make create-data-local HOME=/path/to/parent"
	@echo "   make create-local HOME=/path/to/parent"
	@echo "   make start"
	@echo ""
	@echo "Note: HOME can be omitted and it will default to your home directory."
	@echo ""

create-data-local:
	mkdir -p $(HOME)/data/etc
	mkdir -p $(HOME)/data/root
	mkdir -p $(HOME)/data/dynamic
	mkdir -p $(HOME)/data/settings
	mkdir -p $(HOME)/data/log
	mkdir -p $(HOME)/data/var
	@echo "Generating $(HOME)/data/etc/agraph.cfg"
	@sed "s/\$$ADMIN_USER/$(ADMIN_USER)/g" $(ROOT_DIR)/agraph.in | sed "s/\$$ADMIN_PASSWORD/$(ADMIN_PASSWORD)/g" | sed "s/\$$PORT/$(PORT)/g" | sed "s/\$$SSL_PORT/$(SSL_PORT)/g" > $(HOME)/data/etc/agraph.cfg

create-local:
	docker create -m $(MEMSIZE) -p $(PORT):$(PORT) --shm-size $(SHMSIZE) --name $(NAME) -v $(HOME)/data:/data $(IMAGE)

create-data-image:
	@echo "Generating agraph.cfg"
	@sed "s/\$$ADMIN_USER/$(ADMIN_USER)/g" $(ROOT_DIR)/agraph.in | sed "s/\$$ADMIN_PASSWORD/$(ADMIN_PASSWORD)/g" | sed "s/\$$PORT/$(PORT)/g" | sed "s/\$$SSL_PORT/$(SSL_PORT)/g" > agraph.cfg
	docker build -f Dockerfile-data.txt -t $(DATA_IMAGE) .
	@rm -f agraph.cfg

create-data:
	docker create --name $(DATA_NAME) $(DATA_IMAGE)

create:
	docker create -m $(MEMSIZE) -p $(PORT):$(PORT) --shm-size $(SHMSIZE) --name $(NAME) --volumes-from $(DATA_NAME) $(IMAGE)

remove:
	docker rm $(NAME)

remove-data:
	docker rm $(DATA_NAME)

remove-data-image:
	docker image rm $(DATA_IMAGE)

start:
	docker start $(NAME)

stop:
	docker stop $(NAME)

shell:
	docker run -i -t --rm=true -m $(MEMSIZE) --shm-size $(SHMSIZE) --volumes-from $(DATA_NAME) $(IMAGE) /bin/bash

shell-data:
	docker run -i -t --rm=true --volumes-from $(DATA_NAME) $(DATA_IMAGE) /bin/bash
