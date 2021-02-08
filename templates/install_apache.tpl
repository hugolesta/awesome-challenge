#!/bin/bash -x 
sudo yum -y install httpd
sudo service httpd start  

echo "Thanks for the awesome challenge, done!" > /var/www/html/index.html