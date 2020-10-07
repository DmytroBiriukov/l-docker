ARG PHP_FPM_VERSION=7.2

FROM php:${PHP_FPM_VERSION}-fpm-alpine

#
# Install dependencies
#
#   runtime dependencies
#       - libpng (required by gd extension, Error "Unable to load dynamic library")
#       - libjpeg-turbo (required by gd extension, Error "Unable to load dynamic library")
#       - freetype (required by gd extension, Error "Unable to load dynamic library")
#   build dependencies
#       - libpng-dev (required by gd, error without it)
#       - libjpeg-turbo-dev (optional by gd, support jpeg, requrired --with-jpeg-dir=/usr/include/)
#       - freetype-dev (optional by gd, support freetype, required --with-freetype-dir=/usr/include/)
#
# Compile extensions from source, auto enabled after compiled (/usr/src/php-*)
#
#   bcmath - required by laravel starting from 5.7
#   pdo_mysql - required by laravel database component
#
# Install extension using pecl
#
#   xdebug - required for developers
#  
RUN set -xe \
		&& apk add --no-cache \
			libpng \
			libjpeg-turbo \
			freetype \
		&& apk add --no-cache --virtual .make-ext-deps \
			libpng-dev \
			libjpeg-turbo-dev \
			freetype-dev \
			$PHPIZE_DEPS \
			imagemagick \
            imagemagick-libs \
            imagemagick-dev \
		&& docker-php-ext-configure gd \
			--with-freetype-dir=/usr/include/ \
			--with-jpeg-dir=/usr/include/ \
		&& docker-php-ext-install -j$(nproc) \
			gd \
			bcmath \
			pdo_mysql \
			exif \
		&& pecl install xdebug-2.6.1 \
			imagick \
	 	&& docker-php-ext-enable \
		 	imagick \	
		&& rm -rf /usr/src/* /tmp/* 		

#  
# Install extra packages
#
#	curl - already installed
#	crond - already installed
#	zip - php mark own zip extension as depricated, it use system lib
#
RUN set -xe \
		&& apk add --no-cache \
			zip \
			nano \
			bash 

RUN set -xe \
		&& apk add --no-cache \
			wkhtmltopdf

### Configure user
ENV DOCKER_USER=www

ARG DOCKER_UID=1000
ARG DOCKER_GID=1000

### Add host user and group into container
RUN set -xe \
		&& addgroup -g $DOCKER_GID $DOCKER_USER \
		&& adduser -g "web user" -s /bin/sh -D -u $DOCKER_UID -G $DOCKER_USER $DOCKER_USER \
		&& delgroup $DOCKER_USER $DOCKER_USER \
		&& echo "$DOCKER_USER:$DOCKER_USER" | chpasswd

ENV PROJECT_ID=l-docker
### Set working directory
WORKDIR /var/www/$PROJECT_ID

#
# Run php-fpm with docker user
# Increase memory limit for php
# Install composer
# Link composer cache into project folder
#
ARG COMPOSER_VERSION=1.8.5

RUN curl https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION

### Copy ssl certificate for curl
COPY cacert.pem /etc/ssl/certs/cacert.pem

RUN set -xe \
		&& echo -e "\n[www]\nuser = $DOCKER_USER\ngroup = $DOCKER_USER" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
		&& echo -e "memory_limit=4092M\n" > /usr/local/etc/php/conf.d/memory.ini \
		&& echo -e "max_execution_time=0\n" > /usr/local/etc/php/conf.d/max_execution_time.ini \
		&& echo -e "curl.cainfo=\"/etc/ssl/certs/cacert.pem\"\n" > /usr/local/etc/php/conf.d/curl_cainfo.ini \
		&& echo -e "extension=$(find /usr/local/lib/php/extensions/ -name gd.so)\n" > /usr/local/etc/php/conf.d/docker-php-ext-gd.ini 		

### Download, extract and move binary in place
COPY source/ .
### For example if you need to copy archived wkhtmltopdf into /usr/local/bin inside container  
#RUN tar -xf wkhtmltopdf.tar.xz
#RUN cp wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
#RUN chmod +x /usr/local/bin/wkhtmltopdf

RUN docker-php-ext-install opcache
COPY docker/app/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

### Extend entry point
COPY docker-ep-extra.sh /

RUN set -xe \
		&& sed -i '/^set -e/r /docker-ep-extra.sh' /usr/local/bin/docker-php-entrypoint \
		&& rm -f /docker-ep-extra.sh

# Cron tasks
RUN chmod -R 644 /etc/crontabs 
