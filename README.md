Docker Ansible
==============

> Docker image to use Ansible without install it

| CI / CD | Status |
| ------- | ------ |
| Semaphore | [![Build Status](https://sineverba.semaphoreci.com/badges/docker-ansible/branches/master.svg?style=shields&key=d89eb6a8-f51b-4e24-b499-ac66d6b57d95)](https://sineverba.semaphoreci.com/projects/docker-ansible) |


## Run

1. Copy your ssh keys into destination servers / desktops

    `ssh-copy-id -i /home/sineverba/.ssh/id_ed25519.pub sineverba@192.168.1.32`


2. Be sure that you can log to the server / desktop without password

    `ssh sineverba@192.168.1.32`

3. Launch Ansible with

    ```shell
    docker run \
	--rm -it \
	-v ${pwd}/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name ansible \
	sineverba/ansible:1.0.0 \
	# -v or -vvv or -vvvv for debug
	-i /playbook/inventory.yml \
	/playbook/desktop.yml \ # select your playbook
	-e username=sineverba \ # select your username
	-e ansible_become_pass=your-password! # your root passwd
    ```

3. To pass the password of sudo, append `--extra-vars 'ansible_become_pass=your-password'`

## Available architectures

+ linux/arm64/v8
+ linux/amd64


### Upgrade requirements
1. Run Dockerfile.upgrade with `$ make upgrade`
2. Copy and paste the output of previous command inside `requirements.txt`
3. Run `$ make build`