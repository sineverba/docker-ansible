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
| `base/common.yml` | Common base setup |
| `base/desktop.yml` | Setup desktop environment |
| `base/server.yml` | Setup server environment |
| `services/claude-code.yml` | Install Claude Code |
| `services/pihole.yml` | Configure DNS for PiHole (run after `base/server.yml`) |
| `services/server-wifi.yml` | Mark carrier-less wired interfaces as `optional` in netplan (fixes slow boot on WiFi-only servers) |
| `utils/test.yml` | Print system facts (for testing) |

## Setup

1. Install `openssh-server` on target machine

        apt-get install openssh-server

2. Copy your SSH key to target

        ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.32

3. Verify passwordless login

        ssh user@192.168.1.32

4. On **Ubuntu 24.04+ targets**, switch `sudo` away from `sudo-rs` to classic GNU sudo — otherwise Ansible's `become` will time out (see [Known issues](#known-issues-ubuntu-2404-targets-and-sudo-rs) below)

        ssh user@192.168.1.32 "sudo update-alternatives --set sudo /usr/bin/sudo.ws"

## Usage

### Generic

```shell
docker run \
    --rm -it \
    -v $(PWD)/playbook:/playbook:ro \
    -v ~/.ssh:/ssh:ro \
    --name ansible \
    sineverba/ansible:2.1.0 \
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
| `make server-wifi` | Mark carrier-less wired interfaces as `optional` in netplan |
| `make upgrade` | Upgrade Python dependencies |
| `make get-latest-pip` | Print latest available pip version |
| `make update-pip-version` | Update `PIP_VERSION` in Makefile to latest |

`playtest`, `desktop`, `server`, `pihole` and `server-wifi` accept `username` and `ansible_become_pass` overrides from the command line (default to `user`/`password`):

```shell
make server username=myuser ansible_become_pass=mypassword
```

## Known issues

### Ubuntu 24.04+ targets and sudo-rs

`Timeout (12s) waiting for privilege escalation prompt` — Ubuntu 24.04+ defaults `/usr/bin/sudo` to **sudo-rs** (the Rust reimplementation) instead of classic GNU sudo. sudo-rs implements the `-p/--prompt` flag differently: instead of *replacing* the whole prompt (like GNU sudo), it appends the custom text to its own fixed prompt. Ansible's `become` mechanism relies on setting a unique `-p` prompt to reliably detect when to send the password — with sudo-rs that unique prompt never appears verbatim, so Ansible times out waiting for it, even with the correct password. This is a known incompatibility (tracked upstream: [trifectatechfoundation/sudo-rs#1461](https://github.com/trifectatechfoundation/sudo-rs/issues/1461), [ansible/ansible#85837](https://github.com/ansible/ansible/issues/85837)) and the Ansible-side fix ([ansible/ansible#86175](https://github.com/ansible/ansible/pull/86175)) has not shipped in any released ansible-core version yet (merged to `devel` after the `stable-2.21` branch point).

**Fix**: on the target host, both `sudo` (classic) and `sudo-rs` are typically installed side by side, managed via `update-alternatives`. Switch the active alternative to classic sudo:

```shell
ssh user@target "sudo update-alternatives --set sudo /usr/bin/sudo.ws"
```

Verify with `ssh user@target "readlink -f /usr/bin/sudo && sudo --version"` — it should point to `/usr/bin/sudo.ws` and report a classic `Sudo version 1.9.x`, not `sudo-rs`.