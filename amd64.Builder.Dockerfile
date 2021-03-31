FROM centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

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
 && yum install -y \
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
 && yum-config-manager \
        --enable remi-php74 \
 && yum clean all
