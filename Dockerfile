FROM centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

RUN yum update -y \
 && yum upgrade -y

RUN yum install -y \
    git \
    httpd \
    mariadb-server \
    nano \
    ntp \
    openssh-server \
    tar \
    unzip \
    vsftpd \
    wget

RUN yum install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    http://rpms.remirepo.net/enterprise/remi-release-7.rpm

RUN yum install -y \
    yum-utils \
 && yum-config-manager --enable remi-php72 \
 && yum install -y \
    php \
    php-mysql \
    php-soap

RUN systemctl enable ntpd \
 && systemctl enable vsftpd \
 && systemctl enable httpd \
 && systemctl enable mariadb

RUN rm -f /etc/vsftpd/ftpusers \
          /etc/vsftpd/user_list \
 && sed -e "s/listen=.*$/listen=YES/g" \
        -e "s/listen_ipv6=.*$/listen_ipv6=NO/g" \
        -e "s/userlist_enable=.*/userlist_enable=NO/g" \
        -i /etc/vsftpd/vsftpd.conf