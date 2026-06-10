#!/bin/bash
# Funzione per ottenere la versione installata di Docker Compose
get_installed_version() {
  if [ -x "/usr/local/lib/docker/cli-plugins/docker-compose" ]; then
    INSTALLED_VERSION=$(/usr/local/lib/docker/cli-plugins/docker-compose --version | grep -oP "\d+\.\d+\.\d+")
  else
    INSTALLED_VERSION="none"
  fi
}

# Ottieni la versione più recente di Docker Compose
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# Rimuovi la 'v' dalla versione più recente, se presente
LATEST_VERSION=${LATEST_VERSION#v}

# Ottieni l'architettura e il sistema operativo della macchina
ARCH=$(uname -m)
OS=$(uname | tr '[:upper:]' '[:lower:]')

# Se il sistema è MacOS, cambia l'OS in "darwin"
if [ "$OS" = "darwin" ]; then
  OS="darwin"
fi

# Costruisci l'URL per il download di Docker Compose
URL="https://github.com/docker/compose/releases/download/v${LATEST_VERSION}/docker-compose-${OS}-${ARCH}"

# Ottieni la versione installata di Docker Compose
get_installed_version

# Confronta le versioni e scarica la nuova versione solo se è diversa da quella installata
if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating Docker Compose from version $INSTALLED_VERSION to $LATEST_VERSION"
  curl -L $URL -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  echo "Docker Compose updated to version $LATEST_VERSION"
else
  echo "Docker Compose is already up-to-date (version $INSTALLED_VERSION)"
fi
# Update system
apt update -y && \
apt-get update -y && \
apt-get upgrade -y && \
apt dist-upgrade -y && \
apt-get autoremove -y && \
apt-get clean -y && \
apt-get autoclean -y && \
apt purge -y
