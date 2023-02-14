IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
APP_VERSION=1.6.0-dev
BUILDX_VERSION=0.10.2
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

multi:
	docker buildx build \
		--platform linux/arm64/v8,linux/amd64 \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file Dockerfile "."

build:
	docker build --tag $(IMAGE_NAME):$(APP_VERSION) --file Dockerfile "."

upgrade:
	sed -i 's/==/>=/' requirements.txt
	docker build \
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
	--skip-tags "copysshkeys,pihole" \
	-i /playbook/inventory.yml \
	/playbook/server.yml \
	-e username=user \
	-e ansible_become_pass=password

test:
	docker run --rm -it --entrypoint cat --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) /etc/os-release | grep "Debian GNU/Linux 10 (buster)"
	docker run --rm -it --entrypoint python --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) --version | grep "Python 3.11.1"
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) | grep "core 2.14.2"
	docker run --rm -it --entrypoint ssh --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) -V | grep "9.2"


destroy:
	docker image rm $(IMAGE_NAME):$(APP_VERSION)
