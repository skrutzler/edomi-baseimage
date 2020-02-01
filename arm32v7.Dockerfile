FROM starwarsfan/edomi-baseimage-builder:arm32v7-latest as builder
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>
RUN yum -y install mosquitto mosquitto-devel php-devel \
 && cd /tmp \
 && git clone https://github.com/mgdm/Mosquitto-PHP \
 && cd Mosquitto-PHP \
 && phpize \
 && ./configure \
 && make \
 && make install DESTDIR=/tmp/Mosquitto-PHP

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
        epel-release \
 && yum update -y \
 && yum install -y \
        ca-certificates \
        file \
        git \
        hostname \
        httpd \
        mariadb-server \
        mod_ssl \
        mosquitto \
        mosquitto-devel \
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
        php-zip \
 && yum clean all

# Telegram-LBS
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

# Mailer-LBS 19000587
RUN cd /usr/local/edomi/main/include/php/ \
 && mkdir PHPMailer \
 && cd PHPMailer \
 && composer require phpmailer/phpmailer

# Mosquitto-LBS
COPY --from=builder /tmp/Mosquitto-PHP/modules /usr/lib64/php/modules/
RUN echo 'extension=mosquitto.so' > /etc/php.d/50-mosquitto.ini

# MikroTik-LBS
RUN yum -y update \
        nss \
 && yum clean all \
 && cd /usr/local/edomi/main/include/php \
 && git clone https://github.com/jonofe/Net_RouterOS \
 && cd Net_RouterOS \
 && composer install

# Edomi
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

# Remove limitation to only one installed language
RUN sed -i "s/override_install_langs=.*$/override_install_langs=all/g" /etc/yum.conf \
 && yum update -y \
 && yum reinstall -y \
        glibc-common \
 && yum clean all
