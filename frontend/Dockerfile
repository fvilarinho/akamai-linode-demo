# Define the base linux distribution.
FROM alpine:edge

# Define the maintainer of the project.
LABEL maintainer="fvilarinho@gmail.com"

# Default environment variables.
ENV HOME_DIR=/home/user
ENV ETC_DIR=${HOME_DIR}/etc
ENV BIN_DIR=${HOME_DIR}/bin
ENV HTDOCS_DIR=${HOME_DIR}/htdocs
ENV IMAGES_DIR=${HTDOCS_DIR}/images
ENV JS_DIR=${HTDOCS_DIR}/js

# Install essential packages.
RUN apk update && \
    apk add --no-cache bash ca-certificates curl wget vim net-tools bind-tools nginx

# Install the required directories.
RUN adduser -S user -G www-data && \
    mkdir -p ${ETC_DIR} ${BIN_DIR} ${IMAGES_DIR} ${JS_DIR} && \
    mkdir -p /run/nginx && \
    rm -rf /etc/nginx/http.d/default.conf

# Copy the default configurations, boot script and static content.
COPY bin/startup.sh ${BIN_DIR}/startup.sh
COPY etc/nginx ${ETC_DIR}/nginx
COPY htdocs ${HTDOCS_DIR}

# Set the startup.
RUN chown -R user:www-data ${HOME_DIR} && \
    chmod -R o-rwx ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${ETC_DIR}/nginx/conf.d/default.conf /etc/nginx/http.d/default.conf && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Set default work directory.
WORKDIR ${HOME_DIR}

# Set the default port.
EXPOSE 80

# Boot script.
ENTRYPOINT ["/entrypoint.sh"]