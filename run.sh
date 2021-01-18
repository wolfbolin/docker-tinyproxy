#!/bin/bash
docker_name="tinyproxy"
docker stop ${docker_name}
docker rm ${docker_name}
docker run -d \
	--name='tinyproxy' \
	-p 12800:8888 \
	-v $(pwd)/conf:/etc/tinyproxy \
	tinyproxy:latest ANY
docker logs -f tinyproxy
