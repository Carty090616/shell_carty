#!/usr/bin/env bash 

echo '########################卸载旧版docker########################'
echo /n

yum remove docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine

echo "########################安装需要的包########################"
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

echo "########################设置仓库地址########################"
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

echo "########################安装最新版########################"
yum install docker-ce docker-ce-cli containerd.io

echo "########################启动docker########################"
systemctl start docker

echo "########################验证docker 是否安装成功########################"
docker run hello-world

echo "########################开机自启动########################"
systemctl enable docker

echo "########################切换数据源########################"
echo 
'{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}'>>/etc/docker/daemon.json
cat /etc/docker/daemon.json
service docker restart