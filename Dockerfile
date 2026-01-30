FROM alpine:3.19

RUN apk add --no-cache curl busybox-suid
RUN apk add --no-cache coreutils grep

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]