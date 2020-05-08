#!/bin/sh
app_name="eureka"
#sh /usr/local/${app_name}/service.sh restart
# $1--模块名称
# $2--配置文件名（环境名称）
sh /usr/local/$1/service.sh restart "$1" "$2"

