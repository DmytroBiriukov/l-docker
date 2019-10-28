ARG PHP_VERSION=${PHP_VERSION}
FROM php:${PHP_VERSION}-alpine

RUN apk --update add wget \
  curl \
  git \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  pcre-dev \
  zlib-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  libzip-dev \
  mysql-client \
  gmp gmp-dev \
  supervisor

RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml pcntl bcmath exif

RUN pecl channel-update pecl.php.net \
    && pecl install memcached mcrypt-1.0.1 mongodb \
    && docker-php-ext-enable memcached mongodb

RUN docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip gmp 

### GD and Imagick extensions
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
		&& pecl install xdebug-2.6.1 \
			imagick \
		&& docker-php-ext-enable \
			imagick \	
		&& rm -rf /usr/src/* /tmp/*


RUN set -xe \		
	&& echo -e "memory_limit=4092M\n" > /usr/local/etc/php/conf.d/memory.ini \
	&& echo -e "max_execution_time=0\n" > /usr/local/etc/php/conf.d/max_execution_time.ini				

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

###############################################################
ENV PUID ${DOCKER_UID}
ENV PGID ${DOCKER_GID}
###############################################################

RUN rm /var/cache/apk/* \
    && mkdir -p /var/www

# Modify the ./supervisor.conf file to match your App's requirements.
# Make sure you rebuild your container with every change.
COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

# Check PHP version
RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

WORKDIR /etc/supervisor/conf.d/
