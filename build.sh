#!/bin/bash
docker_name="tinyproxy"
docker build -f Dockerfile --tag ${docker_name}:latest .
