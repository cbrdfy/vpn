// Create EC2 role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "ec2_access_to_s3"
  }
}
// Create S3 policy
resource "aws_iam_policy" "s3_access" {
  name        = "s3_access"
  path        = "/"
  description = "Allow List Get Delete Put"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::wg-vpn-bucket",
            "arn:aws:s3:::wg-vpn-bucket/*"
          ]
        }
      ]
    }
  )

  tags = {
    Name = "S3_Access_Policy"
  }
}

// Attaches a Managed IAM Policy to an IAM role
resource "aws_iam_role_policy_attachment" "attach_ec2_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

// 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
