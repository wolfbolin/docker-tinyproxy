FROM alpine:3.10

RUN apk add --no-cache \
	bash \
	tinyproxy

COPY run.sh /usr/local/tinyproxy/run.sh

ENTRYPOINT ["/usr/local/tinyproxy/run.sh"]
