FROM alpine:3.21.2

RUN apk add curl jq bash

WORKDIR /app

USER 1000

COPY --chown=1000:1000 check-job.sh check-job.sh

