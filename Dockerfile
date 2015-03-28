# VERSION 0.1
# DOCKER-VERSION  0.7.3
# AUTHOR:         Matt Williams <matt@matthewkwilliams.com>
# DESCRIPTION:    Image with docker-registry project and dependecies for Raspberry Pi. Built from X86_64 version by Sam Alba <sam@docker.com>
# TO_BUILD:       docker build -rm -t rpi-registry .
# TO_RUN:         docker run -p 5000:5000 rpi-registry

FROM hypriot/rpi-python

# Update
RUN apt-get update \
# Install pip
    && apt-get install -y \
        swig \
	build-essential \
        python-pip \
# Install deps for backports.lzma (python2 requires it)
        python-dev \
        python-mysqldb \
        libssl-dev \
        liblzma-dev \
        libevent-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /docker-registry
COPY ./config/boto.cfg /etc/boto.cfg

# python-rsa
run pip install rsa

# boto
run pip install boto

# Install core
RUN pip install /docker-registry/depends/docker-registry-core

# Install registry
RUN pip install file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

RUN patch \
 $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

CMD ["docker-registry"]
