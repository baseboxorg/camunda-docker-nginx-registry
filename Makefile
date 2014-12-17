IMAGE_NAME=camunda/camunda-nginx-registry
TAG=latest
IMAGE=$(IMAGE_NAME):$(TAG)
NAME=nginx-registry
OPTS=--name $(NAME) -p 80:80 -p 443:443 $(FLAGS)

DOCKER=docker $(DOCKER_OPTS)
REMOVE=true
FORCE_RM=true
PROXY_IP=$(shell $(DOCKER) inspect --format '{{ .NetworkSettings.IPAddress }}' http-proxy 2> /dev/null)
PROXY_PORT=8888
DOCKERFILE=Dockerfile
DOCKERFILE_BAK=$(DOCKERFILE).http.proxy.bak


build:
	$(DOCKER) build --rm=$(REMOVE) --force-rm=$(FORCE_RM) -t $(IMAGE) .

proxy:
ifneq ($(strip $(PROXY_IP)),)
	cp $(DOCKERFILE) $(DOCKERFILE_BAK)
	sed -i "2i ENV http_proxy http://$(PROXY_IP):$(PROXY_PORT)" $(DOCKERFILE)
endif
	-$(DOCKER) build --rm=$(REMOVE) --force-rm=$(FORCE_RM) -t $(IMAGE) .
ifneq ($(strip $(PROXY_IP)),)
	mv $(DOCKERFILE_BAK) $(DOCKERFILE)
endif

run:
	$(DOCKER) run --rm $(OPTS) $(IMAGE)

daemon:
	$(DOCKER) run -d $(OPTS) $(IMAGE)

bash:
	$(DOCKER) run --rm -it $(OPTS) $(IMAGE) /bin/bash

rmf:
	-$(DOCKER) rm -f $(NAME)

rmi:
	$(DOCKER) rmi $(IMAGE)

stage: rmf build
	-$(DOCKER) rm -f registry registry-ui
	$(DOCKER) run -d --name registry -e MIRROR_SOURCE=https://registry-1.docker.io -e MIRROR_SOURCE_INDEX=https://index.docker.io registry
	$(DOCKER) run -d --name registry-ui --link registry:registry -e REGISTRY_URL=http://registry:5000 -e DEBUG=True anigeo/docker-registry-ui
	$(DOCKER) run -d $(OPTS) --link registry:registry --link registry-ui:registry-ui camunda/camunda-nginx-registry


.PHONY: build run daemon bash rmf rmi proxy stage
