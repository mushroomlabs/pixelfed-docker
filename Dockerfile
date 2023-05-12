#######################################################
# Base image
#######################################################
FROM php:8.4-fpm AS base

ARG PIXELFED_UID=1000
ARG PIXELFED_GID=1000
ARG VERSION

RUN getent group ${PIXELFED_GID} || groupadd -r -g ${PIXELFED_GID} pixelfed
RUN getent passwd ${PIXELFED_UID} || useradd -u ${PIXELFED_UID} -g ${PIXELFED_GID} -r -m pixelfed

#######################################################
# system dependencies
#######################################################
RUN apt-get update && apt-get install -y \
    apt-utils \
    ca-certificates \
    curl \
    git \
    gnupg1 \
    gosu \
    locales \
    locales-all \
    moreutils \
    nano \
    procps \
    software-properties-common \
    unzip \
    wget \
    zip \
    gifsicle \
    jpegoptim \
    optipng \
    pngquant \
    ffmpeg \
    mariadb-client \
    postgresql-client

RUN locale-gen && update-locale

#######################################################
# PHP: extensions
#######################################################
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions redis \
    imagick \
    gd \
    intl \
    bcmath \
    zip \
    pcntl \
    exif \
    curl \
    pdo_pgsql \
    pdo_mysql \
    pdo_sqlite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get clean

#######################################################
# Application code
#######################################################

ADD https://github.com/pixelfed/pixelfed.git#${VERSION} /var/www/

RUN chown ${PIXELFED_UID}:${PIXELFED_GID} -R /var/www/

USER ${PIXELFED_UID}

WORKDIR /var/www/

#######################################################
# Composer packages
#######################################################

RUN mkdir -p /var/www/vendor

RUN composer install --no-ansi --no-interaction --optimize-autoloader
