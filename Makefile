DOCKER=docker
CURDIR=$(shell pwd)
CONTAINER=unplug
PORT=4000
IP=$(shell ipconfig getifaddr en0)

shell:
	$(DOCKER) run -it -p $(PORT):$(PORT) -v "$(CURDIR)":/code $(CONTAINER) /bin/bash

iex:
	$(DOCKER) run -it -p $(PORT):$(PORT) -e DISPLAY=$(IP):0 -v /tmp/.X11-unix:/tmp/.X11-unix -v "$(CURDIR)":/code $(CONTAINER) iex -S mix


build:
	$(DOCKER) build -t $(CONTAINER) .

clean:
	$(DOCKER) rmi -f $(CONTAINER)
