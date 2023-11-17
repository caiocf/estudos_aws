
resource "aws_iam_instance_profile" "ec2_instance_profile" {

  name = "ec2_role_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ssm_policy_attachment_ec2_role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_policy" "policy_s3_storage" {
  name        = "s3_policy_attachment_ec2_role"
  description = "Politica usuario assumer role do s3 para storage gateway"

  policy = data.aws_iam_policy_document.policyt_bucket_s3_example.json
}

resource "aws_iam_policy_attachment" "role_s3_policy_attachment" {
  name       = "ec2_role_s3_policy_attachment"
  policy_arn = aws_iam_policy_attachment.ssm_policy_attachment.policy_arn

  roles = [aws_iam_role.ec2_role.name]
}