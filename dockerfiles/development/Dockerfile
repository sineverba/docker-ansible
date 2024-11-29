ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-bookworm
# Install requirements
RUN apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-client sshpass build-essential zlib1g-dev libssl-dev wget libpam0g-dev libselinux1-dev libkrb5-dev
COPY ../../requirements.txt .
RUN pip install -r requirements.txt
COPY dockerfiles/production/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]