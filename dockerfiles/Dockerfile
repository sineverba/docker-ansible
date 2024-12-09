ARG PYTHON_VERSION=3.12.3
FROM python:$PYTHON_VERSION-slim-bookworm
# Update and upgrade
RUN apt-get update -y && apt-get upgrade -y
# Install requirements
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    python3-dev \
    musl-dev \
    build-essential \
    curl \
    rustc \
    cargo && \
    rm -rf /var/lib/apt/lists/*
# Setup PIP and Ansible
RUN pip install pip --upgrade
COPY ../requirements.txt .
RUN pip install -r requirements.txt
COPY dockerfiles/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]