FROM python:3.12.3-slim-bookworm
# Update and upgrade
RUN apt-get update -y && \
    apt-get install -y \
    git \
    make \
    openssh-client
# Create a group and user
ENV USER=nonroot
ENV GROUPNAME=$USER
ENV UID=12345
ENV GID=23456

RUN addgroup \
    --gid "$GID" \
    "$GROUPNAME" \
&&  adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$GROUPNAME" \
    --uid "$UID" \
    $USER
# Tell docker that all future commands should run as the appuser user
USER nonroot
## Install requirements
COPY ../../requirements.txt .
RUN pip install -r requirements.txt