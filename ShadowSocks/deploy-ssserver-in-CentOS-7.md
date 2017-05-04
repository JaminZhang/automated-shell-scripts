#!/bin/bash
# Written by: Jamin Zhang
# Usage: Deploy Shadowsocks Server in CentOS 7

E_WRONG_ARG=65
E_EXISTED=66

if [ $# -ne 3 ]
then
	echo "Usage: `basename $0` Server_Port Password Encryption_Method"
	echo "Example: `basename $0` 8908 password aes-256-cfb"
	exit $E_WRONG_ARG
fi

server_port=$1
password=$2
method=$3

if [ -e /usr/bin/ssserver ]
then
	echo "/usr/bin/ssserver exists, now exit."
	exit $E_EXISTED
fi

# System Init and Optimization

# Turn off the firewall
systemctl status firewalld
systemctl stop firewalld

# Increase the maximum number of open file descriptors
ulimit -HSn 65536
echo -ne "
* soft nofile 65536
* hard nofile 65536
" >> /etc/security/limits.conf
#sed -i 's/ulimit/#ulimit/g' /etc/profile
#echo "ulimit -c unlimited" >> /etc/profile
#source /etc/profile

# Tune the kernel parameters
cat >> /etc/sysctl.conf <<EOF
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
EOF

/sbin/sysctl -p


# Install common software
yum install epel-release -y
yum install lrzsz vim -y
yum install python-pip -y


# Install shadowsocks
pip install shadowsocks

# Config shadowsocks config file
cat > /etc/shadowsocks.json << EOF
{
    "server":"0.0.0.0",
    "server_port":$server_port,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"$password",
    "timeout":300,
    "method":"$method"
}
EOF

/usr/bin/ssserver -c /etc/shadowsocks.json -d start

echo

ss -lntp | grep $server_port

# Config ssserver at startup
server=shadowsocks
if grep -q $server /etc/rc.local
then
	echo "$server have configured in /etc/rc.local"
else
        echo "# Start ssserver" >> /etc/rc.local
        echo "/usr/bin/ssserver -c /etc/shadowsocks.json -d start" >> /etc/rc.local
        grep $server /etc/rc.local
fi
