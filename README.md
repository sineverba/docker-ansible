Docker Ansible
==============
> Docker image to use Ansible without installing it

| CI / CD | Status |
| ------- | ------ |
| Semaphore | [![Build Status](https://sineverba.semaphoreci.com/badges/docker-ansible/branches/master.svg?style=shields&key=a831bec4-7adb-49ad-ae54-9d049cc802e9)](https://sineverba.semaphoreci.com/projects/docker-ansible) |
| CircleCI | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/sineverba/docker-ansible/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sineverba/docker-ansible/tree/master) |

## Available playbooks

| Playbook | Description |
| -------- | ----------- |
| `desktop.yml` | Setup desktop environment |
| `server.yml` | Setup server environment |
| `pihole.yml` | Configure DNS for PiHole (run after `server.yml`) |
| `test.yml` | Print system facts (for testing) |

## Setup

1. Install `openssh-server` on target machine

        apt-get install openssh-server

2. Copy your SSH key to target

        ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.32

3. Verify passwordless login

        ssh user@192.168.1.32

## Usage

### Generic

```shell
docker run \
    --rm -it \
    -v $(PWD)/playbook:/playbook:ro \
    -v ~/.ssh:/ssh:ro \
    --name ansible \
    sineverba/ansible:2.0.0 \
    -i /playbook/inventory.yml \
    /playbook/base/desktop.yml \
    -e username=user \
    -e ansible_become_pass=password
```

Options:
- `-v` / `-vvv` / `-vvvv` for debug verbosity
- `--skip-tags "a,b,c"` to skip specific tags

### Make targets

| Target | Description |
| ------ | ----------- |
| `make build` | Build the Docker image |
| `make test` | Run image smoke tests |
| `make playtest` | Run test playbook on localhost |
| `make desktop` | Run desktop playbook |
| `make server` | Run server playbook |
| `make pihole` | Configure DNS for PiHole |
| `make upgrade` | Upgrade Python dependencies |
| `make get-latest-pip` | Print latest available pip version |
| `make update-pip-version` | Update `PIP_VERSION` in Makefile to latest |