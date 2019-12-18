FROM arm32v7/centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

COPY qemu-arm-static /usr/bin

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
