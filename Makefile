IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
APP_VERSION=1.10.0-dev
PYTHON_VERSION=3.12.1
OPENSSH_VERSION=9.6
BUILDX_VERSION=0.12.1
ANSIBLE_GALAXY_VERSION=8.2.0

preparemulti:
	-docker buildx rm multiarch
	mkdir -vp ~/.docker/cli-plugins
	curl \
		-L \
		"https://github.com/docker/buildx/releases/download/v$(BUILDX_VERSION)/buildx-v$(BUILDX_VERSION).linux-amd64" \
		> \
		~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker buildx create --name multiarch --use

build: 
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg OPENSSH_VERSION=$(OPENSSH_VERSION) \
		--build-arg ANSIBLE_GALAXY_VERSION=$(ANSIBLE_GALAXY_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file Dockerfile "."

multi: preparemulti
	docker buildx build \
		--platform linux/arm64/v8,linux/amd64,linux/arm/v6,linux/arm/v7 \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg OPENSSH_VERSION=$(OPENSSH_VERSION) \
		--build-arg ANSIBLE_GALAXY_VERSION=$(ANSIBLE_GALAXY_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file Dockerfile "."

upgrade:
	mkdir -p req
	cp requirements.txt req/
	sed -i 's/==/>=/' req/requirements.txt
	docker run --rm -v $(PWD)/req:/usr/src/app \
		python:$(PYTHON_VERSION)-slim-bookworm /bin/sh \
		-c "cd /usr/src/app && pip install --upgrade pip && pip install -r requirements.txt && pip freeze > requirements.txt && cat requirements.txt"
	# Copy requirements
	rm -rf requirements.txt
	cp req/requirements.txt requirements.txt
	rm -rf req/
	docker image rm python:$(PYTHON_VERSION)-slim-bookworm

inspect:
	docker run \
	--rm -it \
	--entrypoint /bin/bash \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION)

playtest:
	docker run \
	--rm -it \
	-v $(PWD)/playbook:/playbook:ro \
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
	-v $(PWD)/playbook:/playbook:ro \
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
	-v $(PWD)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(APP_VERSION) \
	--skip-tags "pihole" \
	-i /playbook/inventory.yml \
	/playbook/server.yml \
	-e username=user \
	-e ansible_become_pass=password

test:
	docker run --rm -it --entrypoint cat --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) /etc/os-release | grep "Debian GNU/Linux 12 (bookworm)"
	docker run --rm -it --entrypoint python --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) --version | grep $(PYTHON_VERSION)
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) | grep "core 2.16.2"
	docker run --rm -it --entrypoint ssh --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) -V | grep $(OPENSSH_VERSION)
	docker run --rm -it --entrypoint ansible-galaxy --name $(CONTAINER_NAME) $(IMAGE_NAME):$(APP_VERSION) collection list community.general | grep $(ANSIBLE_GALAXY_VERSION)


destroy:
	docker image rm python:$(PYTHON_VERSION)-slim-bookworm
	docker image rm $(IMAGE_NAME):$(APP_VERSION)
