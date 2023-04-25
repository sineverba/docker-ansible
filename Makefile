IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
APP_VERSION=1.7.0-dev
PYTHON_VERSION=3.11.3
OPENSSH_VERSION=9.3
BUILDX_VERSION=0.10.4
BINFMT_VERSION=qemu-v7.0.0-28
TOPDIR=$(PWD)

preparemulti:
	mkdir -vp ~/.docker/cli-plugins
	curl \
		-L \
		"https://github.com/docker/buildx/releases/download/v$(BUILDX_VERSION)/buildx-v$(BUILDX_VERSION).linux-amd64" \
		> \
		~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker buildx version
	docker run --rm --privileged tonistiigi/binfmt:$(BINFMT_VERSION) --install all
	docker buildx ls
	docker buildx rm multiarch
	docker buildx create --name multiarch --driver docker-container --use
	docker buildx inspect --bootstrap --builder multiarch

multi: preparemulti
	docker buildx build \
		--platform linux/arm64/v8,linux/amd64 \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg OPENSSH_VERSION=$(OPENSSH_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file Dockerfile "."

build:
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg OPENSSH_VERSION=$(OPENSSH_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file Dockerfile "."

upgrade:
	sed -i 's/==/>=/' requirements.txt
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--no-cache \
		--progress=plain \
		-f Dockerfile.upgrade "."
	docker image rm $(IMAGE_NAME):$(APP_VERSION)

inspect:
	docker run \
	--rm -it \
	--entrypoint /bin/sh \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION)

playtest:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION) \
	-i /playbook/inventory.yml \
	/playbook/test.yml \
	-e username=user \
	-e ansible_become_pass=password

desktop:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION) \
	-i /playbook/inventory.yml \
	/playbook/desktop.yml \
	-e username=user \
	-e ansible_become_pass=password

server:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION) \
	--skip-tags "pihole" \
	-i /playbook/inventory.yml \
	/playbook/server.yml \
	-e username=user \
	-e ansible_become_pass=password

test:
	docker run --rm -it --entrypoint cat --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) /etc/os-release | grep "Debian GNU/Linux 10 (buster)"
	docker run --rm -it --entrypoint python --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) --version | grep $(PYTHON_VERSION)
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) | grep "core 2.14.5"
	docker run --rm -it --entrypoint ssh --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) -V | grep $(OPENSSH_VERSION)


destroy:
	docker image rm python:$(PYTHON_VERSION)-slim-buster
	docker image rm $(IMAGE_NAME):$(APP_VERSION)
