FROM arm64v8/centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

COPY qemu-aarch64-static /usr/bin/

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
