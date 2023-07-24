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
            // You need to allow all of this in order s3fs mount to work.
            "s3:ListBucket",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.aws_s3_bucket_name}",
            "arn:aws:s3:::${var.aws_s3_bucket_name}/*"
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

// Create IAM instance profile to associate IAM role with EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
