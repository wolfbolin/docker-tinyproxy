FROM alpine:3.10

RUN apk add --no-cache bash tinyproxy 
RUN mkdir -p /usr/local/tinyproxy && cp /etc/tinyproxy/tinyproxy.conf /usr/local/tinyproxy/tinyproxy.conf

COPY run.sh /usr/local/tinyproxy/run.sh

ENTRYPOINT ["/usr/local/tinyproxy/run.sh"]
