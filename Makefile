DOCKER=docker
CURDIR=$(shell pwd)
CONTAINER=unplug
PORT=4000
IP=$(shell ipconfig getifaddr en0)

shell:
	$(DOCKER) run -it -p $(PORT):$(PORT) -v "$(CURDIR)":/code $(CONTAINER) /bin/bash
.PHONY: shell

iex:
	$(DOCKER) run -it -p $(PORT):$(PORT) -e DISPLAY=$(IP):0 -v /tmp/.X11-unix:/tmp/.X11-unix -v "$(CURDIR)":/code $(CONTAINER) iex -S mix
.PHONY: iex

test:
	$(DOCKER) run -it -p $(PORT):$(PORT) -e DISPLAY=$(IP):0 -v /tmp/.X11-unix:/tmp/.X11-unix -v "$(CURDIR)":/code $(CONTAINER) mix test
.PHONY: test

build:
	$(DOCKER) build -t $(CONTAINER) .
.PHONY: build

clean:
	$(DOCKER) rmi -f $(CONTAINER)
.PHONY: clean
