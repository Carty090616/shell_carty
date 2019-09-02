#!/usr/bin/env bash 

echo "卸载旧版docker"

yum remove docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine

echo "卸载完成"
