IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
APP_VERSION=1.12.3
PYTHON_VERSION=3.14.2
PIP_VERSION=25.3

build: 
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(IMAGE_NAME):$(APP_VERSION) \
		--file dockerfiles/Dockerfile \
		"."

devspin:
	ansible-playbook \
		-i playbook/inventory.yml \
		playbook/test.yml \
		-e username=user \
		-e ansible_become_pass=password

# Get latest available pip version
get-latest-pip:
	@echo "Checking latest available pip version..."
	@LATEST_PIP=$$(docker run --rm python:$(PYTHON_VERSION)-alpine3.22 /bin/sh -c "pip install --upgrade pip > /dev/null 2>&1 && pip --version | awk '{print \$$2}'"); \
	echo "Latest pip version: $$LATEST_PIP"

# Update PIP_VERSION variable in Makefile using the latest version
update-pip-version:
	@echo "Updating PIP_VERSION in Makefile..."
	@LATEST_PIP=$$($(MAKE) --no-print-directory get-latest-pip | grep "Latest pip version:" | cut -d' ' -f4); \
	echo "Updating from $(PIP_VERSION) to $$LATEST_PIP"; \
	sed -i "s/^PIP_VERSION=.*/PIP_VERSION=$$LATEST_PIP/" Makefile; \
	echo "PIP_VERSION updated to $$LATEST_PIP"

upgrade:
	docker run \
		--rm \
		-it \
		--entrypoint /bin/bash \
		--name $(CONTAINER_NAME) \
		-v "$(PWD):/app" \
		$(IMAGE_NAME):$(APP_VERSION) \
		-c "cd app & \
		pip install pip==$(PIP_VERSION) \
		&& pip list --outdated \
		&& sed -i 's/==/>=/' /app/requirements.txt \
		&& pip install -r /app/requirements.txt --upgrade \
		&& pip freeze > /app/requirements.txt \
		&& sed -i 's/>=/==/' /app/requirements.txt"

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
		| grep "core 2.20.0"


destroy:
	# Remove all images with no current tag
	docker rmi $$(docker images $(IMAGE_NAME):* --format "{{.Repository}}:{{.Tag}}" | grep -v '$(APP_VERSION)') || exit 0;
	# Remove all python images
	docker rmi $$(docker images python --format "{{.Repository}}:{{.Tag}}") || exit 0;
	# Remove all dangling images
	docker rmi $$(docker images -f "dangling=true" -q) || exit 0;
	# Remove cached builder
	docker builder prune -f
