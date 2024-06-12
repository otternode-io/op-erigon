# syntax = docker/dockerfile:1.2
FROM docker.io/library/golang:1.21-alpine3.17 AS builder

RUN apk --no-cache add build-base linux-headers git bash ca-certificates libstdc++

WORKDIR /app
ADD . .

RUN make


FROM docker.io/library/alpine:3.17

# install required runtime libs, along with some helpers for debugging
RUN apk add --no-cache ca-certificates libstdc++ tzdata
RUN apk add --no-cache curl jq bind-tools

# Setup user and group
#
# from the perspective of the container, uid=1000, gid=1000 is a sensible choice
# (mimicking Ubuntu Server), but if caller creates a .env (example in repo root),
# these defaults will get overridden when make calls docker-compose
ARG UID=1000
ARG GID=1000
RUN adduser -D -u $UID -g $GID erigon
USER erigon
RUN mkdir -p ~/.local/share/erigon

## then give each binary its own layer
COPY --from=builder /app/erigon /usr/local/bin/erigon


EXPOSE 8545 \
       8551 \
       8546 \
       30303 \
       30303/udp \
       42069 \
       42069/udp \
       8080 \
       9090 \
       6060


ENTRYPOINT ["erigon"]

