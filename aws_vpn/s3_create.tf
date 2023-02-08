resource "aws_s3_bucket" "wg-vpn-bucket" {
  bucket = "wg-vpn-bucket"
  # Required for destroying not empty bucket
  force_destroy = true
  tags = {
    Name = "VPN bucket"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.wg-vpn-bucket.id
  acl    = "private"
}

resource "aws_s3_object" "config_object" {
  bucket = aws_s3_bucket.wg-vpn-bucket.id
  key    = "config/"
}
