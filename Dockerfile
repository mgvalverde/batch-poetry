# 
ARG PY_VERSION=3.8
FROM python:$PY_VERSION-slim-buster

ARG POE_VERSION=master

# Download and install poetry
RUN apt-get update && \
  apt-get install -y openssh-client git

# Create a non root user
RUN useradd -m -s /bin/bash poe
USER poe
WORKDIR /home/poe


# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/$POE_VERSION/get-poetry.py | python -
# docker version >= 17.09
# https://github.com/moby/moby/pull/9934#issuecomment-338922732
ADD --chown=poe https://raw.githubusercontent.com/python-poetry/poetry/$POE_VERSION/get-poetry.py .
ADD --chown=poe buildaux ./

RUN python get-poetry.py $(bash find_version.sh $POE_VERSION) &&\
  rm get-poetry.py find_version.sh

ENV PATH=$PATH:/home/poe/.poetry/bin

# Add ssh hosts
RUN mkdir .ssh && \
  ssh-keyscan github.com > $HOME/.ssh/known_hosts && \
  ssh-keyscan bitbucket.com >> $HOME/.ssh/known_hosts && \
  ssh-keyscan gitlab.com >> $HOME/.ssh/known_hosts


ENTRYPOINT ["bash", "entrypoint.sh"]

