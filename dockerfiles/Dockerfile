ARG PYTHON_VERSION=3.14.2
FROM python:$PYTHON_VERSION-slim-bookworm

RUN apt-get update -y && apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    openssh-client \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install pip --upgrade

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY dockerfiles/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]