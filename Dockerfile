FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y vim curl

# Install PHP and Nginx
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository ppa:ondrej/php -y
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip git nginx ca-certificates \
    php8.3 php8.3-cli php8.3-common php8.3-fpm \
    php8.3-redis php8.3-mysql php8.3-zip php8.3-curl php8.3-xml php8.3-mbstring

# php8.3-fpm needs this directory but doesn't create it
RUN mkdir -p /run/php

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer

# Download and install the Datadog PHP tracer (inside container)
RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php \
  && php datadog-setup.php --php-bin php8.3 \
  && rm datadog-setup.php


WORKDIR /phpslim

ADD . .

RUN composer install --no-dev --optimize-autoloader

# Fix permissions
RUN chown -R www-data:www-data .

# Add custom nginx config
ADD nginx/default /etc/nginx/sites-available/default

# Expose HTTP port
EXPOSE 80

# Default: Start Nginx + PHP-FPM
CMD service php8.3-fpm start && nginx -g "daemon off;"

# Alternate (for debugging / lightweight run without Nginx):
# CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
