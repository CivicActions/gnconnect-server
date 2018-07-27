# Build mattermost binary
FROM golang:stretch as builder

ENV BUILD_PATH=/go/src/github.com/mattermost/mattermost-server
COPY . $BUILD_PATH
WORKDIR $BUILD_PATH
RUN make build-linux

# Create mattermost-server image
FROM debian:9-slim

RUN mkdir -p /mattermost/bin
COPY --from=builder /go/bin /mattermost/bin
