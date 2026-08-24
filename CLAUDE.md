# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A Docker image that runs Ansible without requiring a local installation. The container mounts SSH keys and playbooks at runtime.

## Key commands

```bash
make build          # Build the Docker image
make test           # Run image smoke tests (requires TTY — use docker run directly in non-TTY shells)
make upgrade        # Upgrade pip dependencies inside the container and freeze requirements.txt
make get-latest-pip # Print latest available pip version for the base Python image
```

Running tests without a TTY (CI / Claude Code sessions):
```bash
docker run --rm --entrypoint cat sineverba/ansible:<VERSION> /etc/os-release | grep "Debian GNU/Linux 12 (bookworm)"
docker run --rm --entrypoint python sineverba/ansible:<VERSION> --version | grep "<PYTHON_VERSION>"
docker run --rm sineverba/ansible:<VERSION> | grep "core <ANSIBLE_CORE_VERSION>"
```

## Versioning

All version pins live at the top of `Makefile`: `IMAGE_NAME`, `APP_VERSION`, `PYTHON_VERSION`, `PIP_VERSION`. `requirements.txt` pins every Python dependency with `==`.

## Playbook targets

`playtest`, `desktop`, `server`, `pihole`, `server-wifi` pass `username` and `ansible_become_pass` as `-e` vars to `ansible-playbook`. Both are Makefile variables with defaults (`user`/`password`) declared with `?=` at the top of `Makefile`, so they're overridable from the CLI: `make server username=myuser ansible_become_pass=mypassword`.

`services/server-wifi.yml` targets the `servers` group but self-limits: it detects wired interfaces with no carrier (`/sys/class/net/*/carrier == 0`, excluding wireless/bridge/bonding) on each host at runtime and only touches those — no hardcoded interface/host names, so it's a no-op on hosts without the issue. It edits `optional: true` into netplan via `services/files/set_netplan_optional.py` (PyYAML load/dump), then runs `netplan apply` only if something changed.

## Known issue: sudo-rs breaks `become` on Ubuntu 24.04+ targets

If a playbook run against an Ubuntu 24.04+ host fails with `Timeout (12s) waiting for privilege escalation prompt` even though `ansible_become_pass` is correct, the target is using **sudo-rs** (Ubuntu's default `/usr/bin/sudo` on 24.04+) instead of classic GNU sudo. sudo-rs handles the `-p` prompt flag differently, so Ansible's become-prompt detection never matches — this is a known upstream incompatibility with no fix released yet in any ansible-core version (fix merged to Ansible's `devel` branch, post-2.21). Fix on the target: `ssh user@target "sudo update-alternatives --set sudo /usr/bin/sudo.ws"` (classic sudo is normally installed alongside sudo-rs). See `README.md`'s "Known issues" section for full detail.

## Architecture

| File | Role |
|------|------|
| `dockerfiles/Dockerfile` | Single-stage build on `python:X.Y.Z-slim-bookworm` |
| `dockerfiles/entrypoint.sh` | Copies `/ssh` → `~/.ssh`, fixes permissions, then exec's `ansible-playbook "$@"` |
| `requirements.txt` | Pinned pip deps (ansible, ansible-core, cryptography, etc.) |
| `playbook/` | Ansible playbooks (`desktop.yml`, `server.yml`, `pihole.yml`, `server-wifi.yml`, `test.yml`) and `inventory.yml` |

## CI

Two pipelines run on push to `master`: Semaphore CI (`.semaphore/semaphore.yml`) and CircleCI (`.circleci/`). Both run `make build` then `make test`.

## TODO (open items)

See `TODO.md`. Notable pending work: refactor `desktop`/`server` playbooks, simplify `Makefile`, merge `server`/`desktop` playbooks.
