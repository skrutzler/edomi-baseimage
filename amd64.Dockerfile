FROM starwarsfan/edomi-baseimage-builder:amd64-latest as builder
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

# Dependencies to build stuff
RUN yum -y install mosquitto mosquitto-devel mysql-devel php-devel which

# Now build
RUN cd /tmp \
 && git clone https://github.com/mgdm/Mosquitto-PHP \
 && cd Mosquitto-PHP \
 && phpize \
 && ./configure \
 && make \
 && make install DESTDIR=/tmp/Mosquitto-PHP

RUN cd /tmp \
 && git clone https://github.com/jonofe/lib_mysqludf_sys \
 && cd lib_mysqludf_sys/ \
 && gcc -DMYSQL_DYNAMIC_PLUGIN -fPIC -Wall -I/usr/include/mysql -I. -shared lib_mysqludf_sys.c -o /tmp/Mosquitto-PHP

RUN cd /tmp \
 && git clone https://github.com/mysqludf/lib_mysqludf_log \
 && cd lib_mysqludf_log \
 && autoreconf -i \
 && ./configure \
 && make \
 && make install DESTDIR=/tmp/Mosquitto-PHP

FROM centos:7
MAINTAINER Yves Schumann <y.schumann@yetnet.ch>

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
        net-tools \
        ntp \
        openssh-server \
        tar \
        unzip \
        vsftpd \
        wget \
        yum-utils \
 && yum install -y \
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
 && yum-config-manager \
        --enable remi-php72 \
 && yum install -y \
        php \
        php-curl \
        php-gd \
        php-mbstring \
        php-mysql \
        php-process \
        php-soap \
        php-ssh2 \
        php-xml \
        php-zip \
 && yum clean all

# Alexa
RUN ln -s /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/pki/tls/cacert.pem \
 && sed -i \
        -e '/\[curl\]/ a curl.cainfo = /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem' \
        -e '/\[openssl\] a openssl.cafile = /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem' \
        /etc/php.ini

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
COPY --from=builder /tmp/Mosquitto-PHP/usr/lib64/mysql /usr/lib64/mysql/
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
