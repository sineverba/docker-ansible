ARG PYTHON_VERSION=3.13.5
FROM python:$PYTHON_VERSION-slim-bookworm
# Update and upgrade
RUN apt-get update -y && apt-get upgrade -y
# Install requirements
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    build-essential \
    cargo \
    curl \
    gcc \
    libffi-dev \
    libssl-dev \
    musl-dev \
    pkg-config \
    python3-cryptography \
    python3-cffi \
    python3-dev \
    rustc && \
    rm -rf /var/lib/apt/lists/*
# Setup PIP and Ansible
RUN pip install pip --upgrade
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY dockerfiles/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]