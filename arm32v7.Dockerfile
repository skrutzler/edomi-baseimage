FROM arm32v7/centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

COPY qemu-arm-static /usr/bin/

RUN ls -l /usr/bin/qemu*

# Workaround for https://github.com/multiarch/centos/issues/1
RUN echo "armhfp" > /etc/yum/vars/basearch \
 && echo "armv7hl" > /etc/yum/vars/arch \
 && echo "armv7hl-redhat-linux-gpu" > /etc/rpm/platform

RUN yum update -y \
 && yum upgrade -y

RUN yum install -y \
    git \
    httpd \
    mod_ssl \
    mysql \
    mysql-server \
    nano \
    ntp \
    openssh-server \
    php-devel \
    php-gd \
    php-mbstring \
    php-mysql \
    php-pear \
    php-process  \
    php-snmp \
    php-soap \
    php-xml \
    php-xmlrpc \
    tar \
    unzip \
    vsftpd \
    wget
