# Docker Tinyproxy
使用Docker快速配置启动的Tinyproxy服务

### 使用方法
---
##### 创建Docker容器

```
Usage:
    docker run -d --name='tinyproxy' -p <Host_Port>:8888 --env BASIC_AUTH_USER=<username> --env BASIC_AUTH_PASSWORD=<password> --env TIMEOUT=<timeout> monokal/tinyproxy:latest <ACL>

        - Set <Host_Port> to the port you wish the proxy to be accessible from.
        - Set <ACL> to 'ANY' to allow unrestricted proxy access, or one or more space seperated IP/CIDR addresses for tighter security.
        - Basic auth is optional.
        - Timeout is optional.

    Examples:
        docker run -d --name='tinyproxy' -p 6666:8888 monokal/tinyproxy:latest ANY
        docker run -d --name='tinyproxy' -p 7777:8888 monokal/tinyproxy:latest 87.115.60.124
        docker run -d --name='tinyproxy' -p 8888:8888 monokal/tinyproxy:latest 10.103.0.100/24 192.168.1.22/16
```

### 监控
---
##### 日志
使用`docker logs -f tinyproxy` 可以查看运行日志

