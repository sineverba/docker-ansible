ARG PYTHON_VERSION=3.14.2
FROM python:$PYTHON_VERSION-slim-bookworm

RUN apt-get update -y && apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gcc \
    libffi-dev \
    libssl-dev \
    openssh-client \
    pkg-config \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust only for ARM64 and ARM v7
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ] || [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable; \
    fi
ENV PATH="/root/.cargo/bin:${PATH}"

RUN pip install pip --upgrade
COPY requirements.txt .

# Downgrade cryptography for ARM v6
RUN if [ "$TARGETPLATFORM" = "linux/arm/v6" ]; then \
    sed -i 's/cryptography==46.0.3/cryptography==43.0.3/' requirements.txt; \
    fi

RUN pip install -r requirements.txt

COPY dockerfiles/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]