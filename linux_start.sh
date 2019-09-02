#!/usr/bin/env bash 

echo -e "########################安装 net-tools ########################\n"
yum install net-tools

echo -e "########################安装 vim \n"
yum install -y vim-enhanced

echo "########################安装 iptables ########################\n"
echo -e "停止 firewalld 服务 \n"
systemctl stop firewalld.service

echo -e "\n########################禁止 firewalld 服务在系统启动的时候自动启动\n"
systemctl disable firewalld.service

echo -e "\n########################安装 iptables ########################\n"
yum install -y iptables-services

echo -e "\n########################添加开机启动########################\n"
systemctl enable iptables.service

echo -e "\n########################关闭SELinux########################\n"
echo -e "\n########################编辑前的内容：########################\n"
cat /etc/sysconfig/selinux

sed -i 's|SELINUX=enforcing|SELINUX=disabled|' /etc/sysconfig/selinux

echo -e "\n########################编辑后的内容：########################\n"
cat /etc/sysconfig/selinux

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

echo -e "\n########################daemon.json内容：########################\n"
cat /etc/docker/daemon.json

echo -e "\n########################重启docker########################\n"
service docker restart

# echo -e "########################重启linux########################"
reboot