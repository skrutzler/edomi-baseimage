FROM arm64v8/centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

COPY qemu-arm-static /usr/bin/

# Workaround for https://github.com/multiarch/centos/issues/1
RUN echo "armhfp" > /etc/yum/vars/basearch \
 && echo "armv7hl" > /etc/yum/vars/arch \
 && echo "armv7hl-redhat-linux-gpu" > /etc/rpm/platform

RUN yum update -y \
 && yum upgrade -y \
 && yum install -y \
        ca-certificates \
        epel-release \
        file \
        gcc \
        git \
        make \
        mc \
        ntp \
        openssh-server \
        tar \
        unzip \
        wget \
        yum-utils \
 && yum clean all

COPY epel.repo /etc/yum.repos.d/
COPY php72-testing.repo /etc/yum.repos.d/
COPY remi.repo /etc/yum.repos.d/
