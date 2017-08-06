DOCKER=docker
CURDIR=$(shell pwd)
CONTAINER=unplug

shell:
	$(DOCKER) run -it -v "$(CURDIR)":/code $(CONTAINER) /bin/bash

build:
	$(DOCKER) build -t $(CONTAINER) .

clean:
	$(DOCKER) rmi -f $(CONTAINER)
