#!/bin/bash
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo systemctl restart nginx