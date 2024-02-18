resource "aws_s3_bucket" "wg-vpn-bucket" {
  bucket = var.aws_s3_bucket_name
  # Required for destroying not empty bucket
  force_destroy = true
  tags = {
    Name = "VPN bucket"
  }
}

resource "aws_s3_object" "config_object" {
  bucket = aws_s3_bucket.wg-vpn-bucket.id
  key    = "config/"
}
