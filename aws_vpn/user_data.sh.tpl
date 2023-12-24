#!/bin/bash
echo "-----------------USER_DATA START-----------------"
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
%{ for x in packages ~}
sudo apt-get install ${x} -y
%{ endfor ~}
sudo groupadd docker
sudo usermod -aG docker ${user}
newgrp docker

cat > /home/${user}/docker-compose.yaml <<EOF
---
version: "2.1"
services:
  wireguard:
    image: linuxserver/wireguard:1.0.20210914
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Sweden
      - SERVERURL=auto
      - SERVERPORT=51820
      - PEERS=3
      - PEERDNS=1.1.1.1
      - INTERNAL_SUBNET=10.13.13.0
      - LOG_CONFS=false
    volumes:
      - ${mount_path}/config:/config
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
EOF

chown ${user}:${user} /home/${user}/docker-compose.yaml

export BUCKET="${aws_s3_bucket_name}"
export MOUNT_PATH="${mount_path}"
export REGION="${region}"
mkdir -p $MOUNT_PATH

# Install and configure s3fs
apt-get install s3fs -y
# Mount S3 bucket
s3fs -o allow_other -o iam_role=auto -o endpoint=$REGION -o url="https://s3-$REGION.amazonaws.com" $BUCKET $MOUNT_PATH
# Mount on reboot
echo "s3fs#$BUCKET $MOUNT_PATH fuse allow_other,nonempty,use_path_request_style,iam_role=auto,url=https://s3-$REGION.amazonaws.com,endpoint=$REGION 0 0" >> /etc/fstab

# cd /home/${user}/
docker compose -f /home/${user}/docker-compose.yaml up -d

echo "-----------------USER_DATA END-----------------"
