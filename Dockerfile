FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install PHP
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository ppa:ondrej/php -y
RUN apt-get update && apt-get install -y --no-install-recommends unzip git php8.3 php8.3-cli php8.3-common php8.3-redis php8.3-mysql php8.3-zip php8.3-curl php8.3-xml php-pear php8.3-dev libtool make gcc autoconf libz-dev zip 

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer


WORKDIR /phpslim

ADD . .

# Install required PHP extensions using pecl 
RUN pecl install opentelemetry protobuf && \
    echo "extension=opentelemetry.so" > /etc/php/8.3/cli/conf.d/30-opentelemetry.ini && \
    echo "extension=protobuf.so" > /etc/php/8.3/cli/conf.d/30-protobuf.ini 

# Disable composer plugin security warnings
RUN composer config allow-plugins.php-http/discovery false

RUN composer install --no-dev --optimize-autoloader

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
