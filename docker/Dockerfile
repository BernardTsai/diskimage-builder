#!/usr/bin/env docker build .
FROM ubuntu:latest

LABEL maintainer="bernard@tsai.eu"

# Set standard working directory
WORKDIR /opt/builder

# Install required packages
RUN apt-get update                             && \
    apt-get upgrade -y                         && \
    apt-get install -y git                     && \
    apt-get install -y sudo                    && \
    apt-get install -y qemu                    && \
    apt-get install -y python                  && \
    apt-get install -y python-pip              && \
    apt-get install -y python3                 && \
    apt-get install -y python3-pip             && \
    apt-get install -y debootstrap             && \
    apt-get install -y gdisk                   && \
    apt-get install -y kpartx                  && \
    apt-get install -y curl                    && \
    apt-get install -y squashfs-tools          && \
    apt-get install -y yum                     && \
    apt-get install -y yum-utils

# Install required python packages
RUN pip install pyyaml

# Add diskimage builder
RUN git clone https://opendev.org/openstack/diskimage-builder/ && \
    cd diskimage-builder                                       && \
    pip3 install -e .

# Add diskimage builder utils for openstack
RUN git clone https://opendev.org/openstack/dib-utils/ && \
    cd dib-utils                                       && \
    pip3 install -e .

RUN git clone https://opendev.org/openstack/tripleo-image-elements.git

RUN git clone https://opendev.org/openstack/heat-agents.git && \
    cd heat-agents                                            && \
    sed -i -e 's|^PACKAGES_TO_BE_CLEARED.*|PACKAGES_TO_BE_CLEARED="PyYAML python-ipaddress python-requests"|g' heat-config/install.d/heat-config-source-install/50-heat-config-soure

# Add all additional default packages
COPY files/ /opt/builder/

# Add diskimage builder paths
ENV PATH /opt/builder/diskimage-builder/bin:/opt/builder/dib-utils/bin:$PATH
