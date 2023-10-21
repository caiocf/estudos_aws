resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
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

resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm-session-manager-policy"
  description = "Policy for AWS Systems Manager Session Manager"

  # Permissões necessárias para o Session Manager
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:StartSession",
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ssm_policy_attachment"
  policy_arn = aws_iam_policy.ssm_policy.arn
  roles = [aws_iam_role.ec2_role.name]
}


/*resource "aws_iam_policy_attachment" "attach_amazon_ec2_role_for_ssm" {
  name       = "attach-amazon-ec2-role-for-ssm"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles      = [aws_iam_role.ec2_role.name]
}*/
