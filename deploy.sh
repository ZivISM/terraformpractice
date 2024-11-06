#!/bin/bash

yum update 
yum install docker -y

export PATH=$PATH:/usr/local/bin

systemctl start docker
systemctl enable docker 

groupadd docker 
usermod -aG docker ec2-user

docker pull zivism/netflix-back
docker pull zivism/netflix-front 
docker network create netflix-net
docker run -d --name netflix-front --network netflix-net -p 80:80 netflix-front
docker run -d --name netflix-back --network netflix-net -p 3000:3000 netflix-back