FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV COMPOSER_ALLOW_SUPERUSER=1

# For dev
RUN apt-get update && apt-get install -y vim curl wget

# Install PHP
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository ppa:ondrej/php -y
RUN apt-get update && apt-get install -y --no-install-recommends unzip git php8.3 php8.3-cli php8.3-common php8.3-redis php8.3-mysql php8.3-zip php8.3-curl php8.3-xml

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Install Elastic APM PHP Agent
RUN wget https://github.com/elastic/apm-agent-php/releases/download/v1.15.0/apm-agent-php_1.15.0_amd64.deb && \
    dpkg -i apm-agent-php_1.15.0_amd64.deb && \
    rm apm-agent-php_1.15.0_amd64.deb


WORKDIR /phpslim

ADD . .

RUN composer install --no-dev --optimize-autoloader

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
