#!/usr/bin/env sh
set -e

# Check if directory is mounted
if [ -d "/ssh" ]; then
	cp -pr /ssh /root/.ssh
fi
# Check if config exists
if [ -f "/root/.ssh/config" ]; then
	# Assign right permissions
	chown -R root:root /root/.ssh/config
fi
ansible-playbook $@
