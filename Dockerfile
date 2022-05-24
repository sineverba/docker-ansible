FROM python:3.10.4-slim-buster
# Update and upgrade
RUN apt-get update -y && apt-get upgrade -y
# Install requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-client sshpass build-essential zlib1g-dev libssl-dev wget libpam0g-dev libselinux1-dev libkrb5-dev
# Upgrade openssh
RUN mkdir /var/lib/sshd
RUN chmod -R 700 /var/lib/sshd && chown -R root:sys /var/lib/sshd
RUN wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.9p1.tar.gz
RUN tar -xzf openssh-8.9p1.tar.gz
WORKDIR openssh-8.9p1
RUN ./configure --with-kerberos5 --with-md5-passwords --with-pam --with-selinux --with-privsep-path=/var/lib/sshd/ --sysconfdir=/etc/ssh
RUN make && make install
WORKDIR /
RUN rm -r /openssh-8.9p1 && rm -r openssh-8.9p1.tar.gz
# Setup PIP and Ansible
RUN pip install pip --upgrade
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--version"]