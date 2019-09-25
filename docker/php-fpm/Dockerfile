FROM php:7.2-fpm-alpine

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
	\
		&& apk add --no-cache --virtual .make-ext-deps \
			libpng-dev \
			libjpeg-turbo-dev \
			freetype-dev \
			$PHPIZE_DEPS \
			imagemagick \
            imagemagick-libs \
            imagemagick-dev \
	\
		&& docker-php-ext-configure gd \
			--with-freetype-dir=/usr/include/ \
			--with-jpeg-dir=/usr/include/ \
	\
		&& docker-php-ext-install -j$(nproc) \
			gd \
			bcmath \
			pdo_mysql \
	\
		&& pecl install xdebug-2.6.1 \
			imagick \
	# 		redis-4.2.0 \
	# 		memcached-3.1.3 \
	# \
	 	&& docker-php-ext-enable \
		 	imagick \
	# 		redis \
	# 		memcached \
	\
	#	&& apk del --no-cache --no-network --purge .make-ext-deps \
		&& rm -rf /usr/src/* /tmp/*



#
# Install extra packages
#
#	curl - already installed
#	crond - already installed
#	zip - php mark own zip extension as depricated, it use system lib
#	supervisor - run tasks in background
#
RUN set -xe \
		&& apk add --no-cache \
			zip \
			supervisor


#
# Configure user
#
ENV DOCKER_USER=www

ARG DOCKER_UID=1000
ARG DOCKER_GID=1000


#
# Add host user and group into container
#
RUN set -xe \
		&& addgroup -g $DOCKER_GID $DOCKER_USER \
		&& adduser -g "web user" -s /bin/sh -D -u $DOCKER_UID -G $DOCKER_USER $DOCKER_USER \
		&& delgroup $DOCKER_USER $DOCKER_USER \
		&& echo "$DOCKER_USER:$DOCKER_USER" | chpasswd


#
# Exctend entry point with own code
#
COPY docker-ep-extra.sh /

RUN set -xe \
		&& sed -i '/^set -e/r /docker-ep-extra.sh' /usr/local/bin/docker-php-entrypoint \
		&& rm -f /docker-ep-extra.sh


#
# Set working directory
#
WORKDIR /var/www/mdp


#
# Run php-fpm with docker user
# Increase memory limit for php
# Install composer
# Link composer cache into project folder
#
ARG COMPOSER_VERSION=1.8.5

RUN set -xe \
		&& echo -e "\n[www]\nuser = $DOCKER_USER\ngroup = $DOCKER_USER" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
		&& echo -e "memory_limit=256M\n" > /usr/local/etc/php/conf.d/memory.ini \
		&& curl https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION 
		#&& ln -s $(pwd)/../.composer /home/$DOCKER_USER/.composer

