#!/bin/bash
# The script to setup desired software packages on a fresh Linux

# Install extra repos
wget http://192.168.1.12/repos.d/librehat-shadowsocks-epel-7.repo -O /etc/yum.repos.d/librehat-shadowsocks-epel-7.repo
yum install -y epel-release
# Install software packages
yum install -y htop python34-pip git shadowsocks-qt5 tftp centos-release-scl

# Systemd config changes
## Disable firewalld
systemctl stop firewalld & sytemctl disable firewalld

# Install other software
wget -O- http://192.168.1.12/software/pycharm-community-2016.3.2.tar.gz | tar zx -C /opt
wget -O- http://192.168.1.12/software/sublime_text_3_build_3143_x64.tar.bz2 | tar jx -C /opt