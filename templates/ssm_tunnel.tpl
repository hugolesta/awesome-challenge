#!/bin/bash -x 

yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

pip install aws-ssm-tunnel-agent

echo "[INFO] SSM agent has been installed!"