FROM arm32v7/centos:7
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
        git \
        hostname \
        httpd \
        mariadb-server \
        mod_ssl \
        nano \
        ntp \
        openssh-server \
        tar \
        unzip \
        vsftpd \
        wget \
        yum-utils \
 && yum clean all

COPY epel.repo /etc/yum.repos.d/
COPY php72-testing.repo /etc/yum.repos.d/
COPY remi.repo /etc/yum.repos.d/

RUN yum install -y \
        php \
        php-gd \
        php-mbstring \
        php-mysql \
        php-process \
        php-soap \
        php-xml \
 && yum clean all

RUN cd /tmp \
 && wget --no-check-certificate https://getcomposer.org/installer \
 && php installer \
 && mv composer.phar /usr/local/bin/composer \
 && mkdir -p /usr/local/edomi/main/include/php \
 && cd /usr/local/edomi/main/include/php \
 && git clone https://github.com/php-telegram-bot/core \
 && mv core php-telegram-bot \
 && cd php-telegram-bot \
 && composer install

RUN systemctl enable ntpd \
 && systemctl enable vsftpd \
 && systemctl enable httpd \
 && systemctl enable mariadb

RUN rm -f /etc/vsftpd/ftpusers \
          /etc/vsftpd/user_list \
 && sed -e "s/listen=.*$/listen=YES/g" \
        -e "s/listen_ipv6=.*$/listen_ipv6=NO/g" \
        -e "s/userlist_enable=.*/userlist_enable=NO/g" \
        -i /etc/vsftpd/vsftpd.conf \
 && mv /usr/bin/systemctl /usr/bin/systemctl_ \
 && wget https://raw.githubusercontent.com/starwarsfan/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/bin/systemctl \
 && chmod 755 /usr/bin/systemctl
