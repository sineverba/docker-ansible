Docker Ansible
==============

> Docker image to use Ansible without install it

| CI / CD | Status |
| ------- | ------ |
| Semaphore | [![Build Status](https://sineverba.semaphoreci.com/badges/docker-ansible/branches/master.svg?style=shields&key=a831bec4-7adb-49ad-ae54-9d049cc802e9)](https://sineverba.semaphoreci.com/projects/docker-ansible) |
| CircleCI | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/sineverba/docker-ansible/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sineverba/docker-ansible/tree/master) |

## Available architectures

+ linux/arm64
+ linux/arm/v6
+ linux/arm/v7

## Run

1. (If needed) setup `openssh-server`

	`# apt-get install openssh-server`

1. Copy your ssh keys into destination servers / desktops

    `ssh-copy-id -i /home/sineverba/.ssh/id_ed25519.pub sineverba@192.168.1.32`


2. Be sure that you can log to the server / desktop without password

    `ssh user@192.168.1.32`

3. Launch Ansible with

    ```shell
    docker run \
	--rm -it \
	-v ${pwd}/playbook:/playbook:ro \
	-v ~/.ssh:/ssh:ro \
	--name ansible \
	sineverba/ansible:1.12.3 \
	# -v or -vvv or -vvvv for debug
	# --skip-tags "pihole" \ # Add --skip-tags to skip tags, in the form of --skip-tags "a,b,c"
	-i /playbook/inventory.yml \
	/playbook/desktop.yml \ # select your playbook
	-e username=user \ # select your username
	-e ansible_become_pass=yourRootPasswordHere # your root passwd
    ```

3. To pass the password of sudo, append `--extra-vars 'ansible_become_pass=your-password'`