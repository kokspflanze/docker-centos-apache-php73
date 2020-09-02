FROM centos:centos8

MAINTAINER "KoKsPfLaNzE" <kokspflanze@protonmail.com>

ENV container docker

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# normal updates
RUN yum -y update

# php && httpd
RUN yum -y install php73 php73-php php73-php-opcache php73-php-bcmath php73-php-cli php73-php-common php73-php-gd php73-php-intl php73-php-json php73-php-mbstring php73-php-pdo php73-php-pdo-dblib php73-php-pear php73-php-pecl-mcrypt php73-php-xmlrpc php73-php-xml php73-php-mysql php73-php-soap php73-php-pecl-zip php73-php-pecl-mongodb php73-php-pecl-xdebug php73-php-pecl-yaml httpd

# tools
RUN yum -y install epel-release iproute at curl crontabs git

# pagespeed
RUN curl -O https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm \
 && rpm -U mod-pagespeed-*.rpm \
 && yum clean all \
 && php73 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php73 composer-setup.php --install-dir=bin --filename=composer \
 && php73 -r "unlink('composer-setup.php');" \
 && rm -rf /etc/localtime \
 && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
 && ln -s /bin/php73 /bin/php

# we want some config changes
COPY config/50-php_settings.ini /etc/opt/remi/php73/php.d/
COPY config/v-host.conf /etc/httpd/conf.d/

# create webserver-default directory
RUN mkdir -p /var/www/page/public

EXPOSE 80

RUN systemctl enable httpd \
 && systemctl enable crond

CMD ["/usr/sbin/init"]
