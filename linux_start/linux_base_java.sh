#!/usr/bin/env bash 

echo -e "************************************************************"
echo -e "*                                                          *"
echo -e "*                    安装 expect                         *"
echo -e "*                                                          *"
echo -e "************************************************************"
# yum install expect

echo -e "************************************************************"
echo -e "*                                                          *"
echo -e "*                    安装 net-tools                      *"
echo -e "*                                                          *"
echo -e "************************************************************"
expect -d -c "set timeout 500;
        spawm yum install net-tools;
        expect {
            *yes/no* {send -- yes\r;exp_continue;}
            *assword:* {send -- $3\r;exp_continue;}
            eof        {exit 0;}
        }";

# echo -e "************************************************************"
# echo -e "*                                                          *"
# echo -e "*                       安装 vim                         *"
# echo -e "*                                                          *"
# echo -e "************************************************************"
# yum install -y vim-enhanced

# echo -e "************************************************************"
# echo -e "*                                                          *"
# echo -e "*                      安装 iptables                     *"
# echo -e "*                                                          *"
# echo -e "************************************************************"
# # 停止 firewalld 服务
# systemctl stop firewalld.service
# # 禁止 firewalld 服务在系统启动的时候自动启动
# systemctl disable firewalld.service
# # 安装 iptables
# yum install -y iptables-services
# # 添加开机启动
# systemctl enable iptables.service

# echo -e "************************************************************"
# echo -e "*                                                          *"
# echo -e "*                      关闭 SELinux                      *"
# echo -e "*                                                          *"
# echo -e "************************************************************"
# sed -i 's|SELINUX=enforcing|SELINUX=disabled|' /etc/sysconfig/selinux

# echo -e "************************************************************"
# echo -e "*                                                          *"
# echo -e "*                   JDK 系统环境变量设置                   *"
# echo -e "*                                                          *"
# echo -e "************************************************************"
# cd /usr/java
# tar -xvf jdk.tar
# rm -rf jdk.tar
# # 添加java配置文件
# echo '
# JAVA_HOME=/usr/java/jdk1.8.0_221
# JRE_HOME=$JAVA_HOME/jre
# CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
# PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
# '>>/etc/profile
# # 重新加载配置文件
# source /etc/profile

# echo -e "************************************************************"
# echo -e "*                                                          *"
# echo -e "*                      重启 linux                       *"
# echo -e "*                                                          *"
# echo -e "************************************************************"
# reboot