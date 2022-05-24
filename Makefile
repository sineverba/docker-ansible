IMAGE_NAME=sineverba/ansible
CONTAINER_NAME=ansible
VERSION=1.0.0-dev
TOPDIR=$(PWD)

build:
	docker build --tag $(IMAGE_NAME):$(VERSION) .

upgrade:
	docker build --tag $(IMAGE_NAME):$(VERSION) -f Dockerfile.upgrade .

inspect:
	docker run \
	--rm -it \
	--entrypoint /bin/sh \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION)

playtest:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION) \
	-v \
	-i /playbook/inventory.yml \
	/playbook/test.yml \
	-e username=sineverba \

desktop:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION) \
	-i /playbook/inventory.yml \
	/playbook/desktop.yml \
	-e username=sineverba \
	-e ansible_become_pass=yourpassword

server:
	docker run \
	--rm -it \
	-v $(TOPDIR)/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION) \
	-i /playbook/inventory.yml \
	/playbook/server.yml \
	-e username=sineverba \
	-e ansible_become_pass=yourpassword

test:
	docker run --rm -it --entrypoint cat --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) /etc/os-release | grep "Debian GNU/Linux 10 (buster)"
	docker run --rm -it --entrypoint python --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) --version | grep "Python 3.10.4"
	docker run --rm -it --entrypoint pip3 --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) --version | grep "pip 22.1.1"
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) | grep "core 2.12.6"
	docker run --rm -it --entrypoint ssh --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) -V | grep "8.9"


destroy:
	docker image rm $(IMAGE_NAME):$(VERSION)