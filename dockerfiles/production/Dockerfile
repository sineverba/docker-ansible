ARG PYTHON_VERSION
FROM python:$PYTHON_VERSION-slim-bookworm
# Update and upgrade
RUN apt-get update -y && apt-get upgrade -y
# Install requirements
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    --no-install-recommends \
    build-essential \
    libssl-dev \
    libkrb5-dev \
    libpam0g-dev \
    libselinux1-dev \
    openssh-client \
    sshpass \
    wget \
    zlib1g-dev
# Upgrade openssh
ARG OPEN_SSH_VERSION
RUN mkdir /var/lib/sshd
RUN chmod -R 700 /var/lib/sshd && chown -R root:sys /var/lib/sshd
RUN wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPEN_SSH_VERSION}p1.tar.gz
RUN tar -xzf openssh-${OPEN_SSH_VERSION}p1.tar.gz
WORKDIR openssh-${OPEN_SSH_VERSION}p1
RUN ./configure \
    --with-kerberos5 \
    --with-md5-passwords \
    --with-pam \
    --with-selinux \
    --with-privsep-path=/var/lib/sshd/ \
    --sysconfdir=/etc/ssh
RUN make && make install
WORKDIR /
RUN rm -r /openssh-${OPEN_SSH_VERSION}p1 && rm -r openssh-${OPEN_SSH_VERSION}p1.tar.gz
# Setup PIP and Ansible
RUN pip install pip --upgrade
COPY requirements.txt .
RUN pip install -r requirements.txt
# Setup specific version of Galaxy Collection
ARG ANSIBLE_GALAXY_VERSION
RUN ansible-galaxy collection install community.general:==$ANSIBLE_GALAXY_VERSION
COPY dockerfiles/production/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]