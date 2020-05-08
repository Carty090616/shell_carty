#!/bin/bash
# copy一些Linux初始化安装需要的安装包

SERVERS="192.168.1.76" #这是我需要安装软件的两台机器的ip
PASSWORD=123456789  #这是主机的密码，建议各主机密码设成一样的
USER=root  #登录主机的用户名
JAVA_DIR=/usr/java
SHELL_DIR=/usr/shell

for SERVER in $SERVERS
do
    # 从 known_hosts 文件中删除所有属于 hostname 的密钥
    ssh-keygen -R $SERVER
done

ssh_copy_id_to_all() {
    for SERVER in $SERVERS
    do
        # 调用 auto_ssh_copy_id 方法
        auto_ssh_copy_id $USER $SERVER $PASSWORD
    done
}

auto_ssh_copy_id() {
    expect -d -c "set timeout 500;
        spawn ssh-copy-id $1@$2;
        expect {
            *yes/no* {send -- yes\r;exp_continue;}
            *assword:* {send -- $3\r;exp_continue;}
            eof        {exit 0;}
        }";
}

# 开始运行
ssh_copy_id_to_all

for SERVER in $SERVERS
do
    # # java
    # ssh -o StrictHostKeyChecking=no root@$SERVER mkdir $JAVA_DIR
    # scp /Users/lifeifei/Documents/其他/软件安装包/JDK8/jdk-8u221-linux-x64.tar $USER@$SERVER:$JAVA_DIR/jdk.tar

    # # 初始化shell
    # ssh -o StrictHostKeyChecking=no root@$SERVER mkdir $SHELL_DIR
    # scp /Users/lifeifei/Documents/Code/shell_carty/linux_start/linux_base_java.sh $USER@$SERVER:$SHELL_DIR/linux_base_java.sh

    ssh -o StrictHostKeyChecking=no root@$SERVER $SHELL_DIR/linux_base_java.sh
done