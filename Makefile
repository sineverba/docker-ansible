IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
APP_VERSION=1.10.0-dev
PYTHON_VERSION=3.12.3
OPEN_SSH_VERSION=9.7
ANSIBLE_GALAXY_VERSION=8.6.0
BUILDX_VERSION=0.14.0
BINFMT_VERSION=qemu-v8.1.5-43

devbuild:
	docker build \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file dockerfiles/development/Dockerfile \
		"."

devspin:
	ansible-playbook \
		-i playbook/inventory.yml \
		playbook/test.yml \
		-e username=user \
		-e ansible_become_pass=password

upgrade:
	pip install --upgrade pip
	sed -i 's/==/>=/' requirements.txt
	pip install -r requirements.txt
	pip freeze > requirements.txt
	sed -i 's/>=/==/' requirements.txt

build: 
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg OPEN_SSH_VERSION=$(OPEN_SSH_VERSION) \
		--build-arg ANSIBLE_GALAXY_VERSION=$(ANSIBLE_GALAXY_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file dockerfiles/production/Dockerfile \
		"."

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
	--skip-tags "virtualbox" \
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
	docker run --rm -it \
		--entrypoint \
		cat \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(APP_VERSION) \
		/etc/os-release | grep "Debian GNU/Linux 12 (bookworm)"
	docker run --rm -it \
		--entrypoint \
		python \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(APP_VERSION) \
		--version | grep $(PYTHON_VERSION)
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(APP_VERSION) \
		| grep "core 2.16.6"
	docker run --rm -it \
		--entrypoint \
		ssh \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(APP_VERSION) \
		-V | grep $(OPEN_SSH_VERSION)
	docker run --rm -it \
		--entrypoint \
		ansible-galaxy \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(APP_VERSION) \
		collection list community.general | grep $(ANSIBLE_GALAXY_VERSION)


destroy:
	# Remove all images with no current tag
	docker rmi $$(docker images $(IMAGE_NAME):* --format "{{.Repository}}:{{.Tag}}" | grep -v '$(APP_VERSION)') || exit 0;
	# Remove all python images
	docker rmi $$(docker images python --format "{{.Repository}}:{{.Tag}}") || exit 0;
	# Remove all dangling images
	docker rmi $$(docker images -f "dangling=true" -q) || exit 0;
	# Remove cached builder
	docker builder prune -f
