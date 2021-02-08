#!/bin/bash -x 
sudo yum -y install httpd
sudo service httpd start  

AWS_INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo "Thanks for the awesome challenge, Hello from sdx-ec2-$AWS_INSTANCE_ID instance :) !" > /var/www/html/index.html


