FROM centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

RUN yum update -y \
 && yum upgrade -y \
 && yum install -y \
        ca-certificates \
        checkinstall \
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
