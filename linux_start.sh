#!/usr/bin/env bash 

echo -e '\n########################卸载旧版docker########################\n'

yum remove docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine

echo -e "\n########################安装需要的包########################\n"
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

echo -e "\n########################设置仓库地址########################\n"
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

echo -e "\n########################安装最新版########################\n"
yum install docker-ce docker-ce-cli containerd.io

echo -e "\n########################启动docker########################\n"
systemctl start docker

echo -e "\n########################验证docker 是否安装成功########################\n"
docker run hello-world

echo -e "\n########################开机自启动########################\n"
systemctl enable docker

echo -e "\n########################切换数据源########################\n"
echo '{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}'>>/etc/docker/daemon.json

echo -e "\ndaemon.json内容：\n"
cat /etc/docker/daemon.json

echo -e "\n重启docker\n"
service docker restart