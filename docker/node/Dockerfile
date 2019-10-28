ARG NODE_VERSION=10.16

FROM node:${NODE_VERSION}-alpine

RUN apk add git

### Configure user
ENV DOCKER_USER=www
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000

### Add host user and group into container
RUN set -xe \
		&& deluser node \
		&& addgroup -g $DOCKER_GID $DOCKER_USER \
		&& adduser -g "web user" -s /bin/sh -D -u $DOCKER_UID -G $DOCKER_USER $DOCKER_USER \
		&& delgroup $DOCKER_USER $DOCKER_USER \
		&& echo "$DOCKER_USER:$DOCKER_USER" | chpasswd

WORKDIR /var/www

### Do not stop container, and handle SIGTERM from docker stop or down
CMD node -e 'setInterval(() => {}, 60000); process.on("SIGTERM", () => { process.exit(0); });'