FROM alpine:3.21.2

RUN apk add curl jq

WORKDIR /app

USER appuser

COPY --chown=appuser:appuser check-job.sh check-job.sh

