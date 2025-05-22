#!/bin/bash

# Update and install tools
sudo dnf update -y
sudo dnf install -y git 
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Install MongoDB
cat <<EOF > /etc/yum.repos.d/mongodb-org.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

dnf install -y mongodb-org
systemctl enable mongod
systemctl start mongod

# Install pm2
npm install -g pm2

# Clone your app (replace with your repo)
# Initialize repo without checkout
git clone --filter=blob:none --no-checkout https://github.com/Petsasv/Cloud_Deployment.git /home/ec2-user/
cd /home/ec2-user/

# Enable sparse checkout
git sparse-checkout init --cone
git sparse-checkout set Website

# Now only Website/ is downloaded
cd Website
npm install

# Start your app
pm2 start server.js --name "UsefullWebsite"
pm2 save  #auto-start after reboot   pm2 logs myapp  for logging
pm2 startup --engine systemd
