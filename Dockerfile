FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y \
    git \
    php \
    php-mysql \
    php-zip \
    unzip \
    curl \
    gcc \
    make \
    autoconf \
    php-dev \
    php-pear \
    libtool \
    libz-dev \
    zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /phpslim

COPY . .

# Debugging commands
# RUN ls -la             
# RUN pwd               
# RUN find /phpslim     
# RUN cat composer.json

RUN composer install --no-dev --optimize-autoloader

RUN pecl install grpc opentelemetry protobuf && \
    echo "extension=grpc.so" > /etc/php/8.1/cli/conf.d/30-grpc.ini && \
    echo "extension=opentelemetry.so" > /etc/php/8.1/cli/conf.d/30-opentelemetry.ini && \
    echo "extension=protobuf.so" > /etc/php/8.1/cli/conf.d/30-protobuf.ini
RUN composer config allow-plugins.php-http/discovery false
RUN composer require guzzlehttp/psr7 php-http/guzzle7-adapter open-telemetry/sdk open-telemetry/exporter-otlp open-telemetry/opentelemetry-auto-laravel

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]
