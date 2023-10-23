FROM ubuntu:22.04 as php56

RUN apt-get update && apt-get install -y libtool make gcc autoconf zlib1g-dev zip

RUN pecl install grpc opentelemetry-beta protobuf > /dev/null 

RUN echo "\
[opentelemetry]\
extension=grpc.so\
extension=opentelemetry.so\
extension=protobuf.so" >> //usr/local/etc/php/php.ini


FROM php:8.0 as php80

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /php-slim

COPY . .

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "public/index.php"]
