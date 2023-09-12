#!/bin/bash

sudo yum -y update
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
newgrp docker

wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

cd /
sudo mkdir /efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport DNS-name-aqui:/ /efs

sudo echo "DNS-name-aqui:/     /efs    nfs4    defaults,_netdev,rw    0   0" >> /etc/fstab

cd /efs
sudo touch /efs/docker-compose.yml

sudo echo "version: '2.2' 
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - ./config/php.conf.upload.ini:/usr/local/etc/php/conf.d/uploads.ini
      - ./wp-app:/var/www/html
    environment:
      TZ: America/Sao_Paulo
      # NÃO SE ESQUEÇA DE ALTERAR ESSES VALORES COM BASE NO SEU DB
      WORDPRESS_DB_HOST: endpoint-DB-RDS 
      WORDPRESS_DB_NAME: db-name
      WORDPRESS_DB_USER: db-user
      WORDPRESS_DB_PASSWORD: db-password
    ports:
      - 80:80"  > /efs/docker-compose.yml

docker-compose up -d

