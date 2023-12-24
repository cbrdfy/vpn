provider "aws" {
  region = var.region
  # access_key = ""
  # secret_key = ""
}

data "aws_ami" "latest_debian" {
  owners      = ["136693071363"]
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }
}

// Import already existed Elastic IP
# import {
#   to = aws_eip.vpn_static_ip
#   id = "your_eip_id"
# }

// Create new Elastic IP
resource "aws_eip" "vpn_static_ip" {
  instance   = aws_instance.vpn_server.id
  depends_on = [aws_internet_gateway.gw]

  tags = {
    "Name" = "VPN Elastic IP"
  }
}

resource "aws_key_pair" "nvirginia" {
  key_name   = var.key_name
  public_key = file(var.key_path)
}

resource "aws_instance" "vpn_server" {
  ami                    = data.aws_ami.latest_debian.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.nvirginia.key_name
  subnet_id              = aws_subnet.public[0].id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.allow_vpn_udp.id]
  # associate_public_ip_address = true

  user_data = templatefile("user_data.sh.tpl", {
    user = "admin",
    packages = [
      "docker-ce",
      "docker-ce-cli",
      "containerd.io",
      "docker-compose-plugin"
    ],
    region             = var.region,
    aws_s3_bucket_name = var.aws_s3_bucket_name,
    mount_path         = "/mnt/${var.aws_s3_bucket_name}/"
  })
  tags = {
    Name = "My VPN"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_security_group" "allow_vpn_udp" {
  name        = "allow_vpn_udp"
  description = "Allow VPN inbound traffic"
  vpc_id      = aws_vpc.vpn_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_vpn_udp"
  }
}
