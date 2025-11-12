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
    php8.3-redis php8.3-mysql php8.3-zip php8.3-curl php8.3-xml php8.3-mbstring \
    php-pear php8.3-dev libtool make gcc autoconf libz-dev zip

# php8.3-fpm needs this directory but doesn't create it
RUN mkdir -p /run/php

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer


WORKDIR /phpslim

ADD . .

# Install PECL + enable extensions
RUN pecl install opentelemetry protobuf \
 && echo "extension=opentelemetry.so" > /etc/php/8.3/fpm/conf.d/20-opentelemetry.ini \
 && echo "extension=protobuf.so" > /etc/php/8.3/fpm/conf.d/20-protobuf.ini \
 && echo "extension=opentelemetry.so" > /etc/php/8.3/cli/conf.d/20-opentelemetry.ini \
 && echo "extension=protobuf.so" > /etc/php/8.3/cli/conf.d/20-protobuf.ini

# FOR FPM
# enable FPM stdout capture
RUN sed -i 's/;catch_workers_output = .*/catch_workers_output = yes/' /etc/php/8.3/fpm/pool.d/www.conf

# Append OTEL ENV
RUN { \
    echo 'env[OTEL_SERVICE_NAME] = "cube_sample_php_slim_otel"'; \
    echo 'env[OTEL_EXPORTER_OTLP_COMPRESSION] = "gzip"'; \
    echo 'env[OTEL_EXPORTER_OTLP_PROTOCOL] = "http/protobuf"'; \
    echo 'env[OTEL_PHP_AUTOLOAD_ENABLED] = "true"'; \
    echo 'env[OTEL_PROPAGATORS] = "baggage,tracecontext"'; \
    # optional settings
    echo 'env[OTEL_RESOURCE_ATTRIBUTES] = "cube.environment=UNSET,service.version=1.2.3,mykey1=myvalue1,mykey2=myvalue2"'; \
    # print traces to this file location /var/log/php8.3-fpm.log
    echo 'env[OTEL_TRACES_EXPORTER] = "console"'; \
    echo 'env[OTEL_LOG_LEVEL] = "debug"'; \
    # example for sending traces to CubeAPM OTLP collector
    # echo 'env[OTEL_EXPORTER_OTLP_TRACES_ENDPOINT] = "http://host.docker.internal:4318/v1/traces"'; \
 } >> /etc/php/8.3/fpm/pool.d/www.conf

# FOR CLI
# Use Environment variables (in docker-compose.yml)

# Disable composer plugin security warnings
RUN composer config allow-plugins.php-http/discovery false

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
