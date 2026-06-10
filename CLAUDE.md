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

## Architecture

| File | Role |
|------|------|
| `dockerfiles/Dockerfile` | Single-stage build on `python:X.Y.Z-slim-bookworm` |
| `dockerfiles/entrypoint.sh` | Copies `/ssh` → `~/.ssh`, fixes permissions, then exec's `ansible-playbook "$@"` |
| `requirements.txt` | Pinned pip deps (ansible, ansible-core, cryptography, etc.) |
| `playbook/` | Ansible playbooks (`desktop.yml`, `server.yml`, `test.yml`) and `inventory.yml` |

## CI

Two pipelines run on push to `master`: Semaphore CI (`.semaphore/semaphore.yml`) and CircleCI (`.circleci/`). Both run `make build` then `make test`.

## TODO (open items)

See `TODO.md`. Notable pending work: refactor `desktop`/`server` playbooks, simplify `Makefile`, merge `server`/`desktop` playbooks.
