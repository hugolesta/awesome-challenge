Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
repo_update: true
repo_upgrade: all
packages:
- git
- mlocate
- telnet
runcmd:
- echo "*         hard    nofile      500000" >> /etc/security/limits.conf
- echo "*         soft    nofile      500000" >> /etc/security/limits.conf
- echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
- echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
- echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
- echo "net.ipv4.tcp_fin_timeout = 1" >> /etc/sysctl.conf
- sysctl -p /etc/sysctl.conf
- alternatives --remove java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
- PLACEMENT=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | awk '{ print substr($1, 1, length($1)-1) }'`
- aws configure set default.region $PLACEMENT
- aws configure set default.output text
- INSTANCE_ID=`/opt/aws/bin/ec2-metadata -i | awk '{ print $2 }'`
- IP_ADDRESS=`/opt/aws/bin/ec2-metadata -o | awk '{ print $2 }'`
- DOMAIN=`grep search /etc/resolv.conf | awk '{ print $2 }'`
- HOSTNAME="${prefix}-${role}-$INSTANCE_ID"
- hostname $HOSTNAME
- sed -i "s/#compress/compress/g" /etc/logrotate.conf
- sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=$HOSTNAME/g" /etc/sysconfig/network
- echo "$IP_ADDRESS $HOSTNAME" >> /etc/hosts
- aws ec2 create-tags --resources $INSTANCE_ID --tags Key="Name",Value="$HOSTNAME"

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
Content-Disposition: attachment; filename="z-part-02"
#!/bin/bash

${additional_user_data}
