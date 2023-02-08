output "vpn_server_ip" {
  value = aws_eip.vpn_static_ip.public_ip
}
