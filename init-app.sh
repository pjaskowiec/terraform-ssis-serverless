#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo snap install aws-cli --classic
sudo systemctl start docker
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 012602196656.dkr.ecr.eu-north-1.amazonaws.com
docker pull 012602196656.dkr.ecr.eu-north-1.amazonaws.com/pj-student-app:latest
sudo docker run -i --env "${db_host}" -p 8080:8080 012602196656.dkr.ecr.eu-north-1.amazonaws.com/pj-student-app:latest