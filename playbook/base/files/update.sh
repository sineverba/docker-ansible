#!/bin/bash
set -euo pipefail

get_installed_version() {
  if [ -x "/usr/local/lib/docker/cli-plugins/docker-compose" ]; then
    INSTALLED_VERSION=$(/usr/local/lib/docker/cli-plugins/docker-compose --version | grep -oP "\d+\.\d+\.\d+")
  else
    INSTALLED_VERSION="none"
  fi
}

LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
LATEST_VERSION=${LATEST_VERSION#v}

if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch latest Docker Compose version" >&2
  exit 1
fi

ARCH=$(uname -m)
OS=$(uname | tr '[:upper:]' '[:lower:]')
URL="https://github.com/docker/compose/releases/download/v${LATEST_VERSION}/docker-compose-${OS}-${ARCH}"

get_installed_version

if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating Docker Compose from $INSTALLED_VERSION to $LATEST_VERSION"
  curl -L "$URL" -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  echo "Docker Compose updated to $LATEST_VERSION"
else
  echo "Docker Compose is already up-to-date ($INSTALLED_VERSION)"
fi

apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove --purge -y
apt-get clean -y
apt-get autoclean -y

snap refresh

if [ -f /var/run/reboot-required ]; then
  echo "*** System reboot required ***"
fi
