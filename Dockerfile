# Build mattermost binary
FROM golang:stretch as builder

ENV BUILD_PATH=/go/src/github.com/mattermost/mattermost-server
COPY . $BUILD_PATH
WORKDIR $BUILD_PATH
RUN make build-linux

# Create mattermost-server image
FROM debian:9-slim

ENV PATH="/mattermost/bin:${PATH}"
ARG PUID=2000
ARG PGID=2000

RUN mkdir -p /mattermost/bin
COPY --from=builder /go/bin /mattermost/bin
COPY config/default.json /config.json.save
COPY i18n /mattermost/i18n

RUN apt-get update && apt-get -y install netcat

RUN mkdir -p /mattermost/data \
    && mkdir /mattermost/logs && mkdir /mattermost/config

# Get ready for production
RUN groupadd -g ${PGID} mattermost \
    && useradd -u ${PUID} -g ${PGID} -d /mattermost mattermost \
    && chown -R mattermost:mattermost /mattermost /config.json.save

#USER mattermost

#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# Configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config"]
