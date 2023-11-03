resource "aws_iam_instance_profile" "ec2_instance_profile" {
  depends_on = [null_resource.checkEc2InstanceProfile,aws_iam_role.ec2_role]

  count = local.ec2InstanceProfileExist == false ? 1 : 0

  name =  local.ec2InstanceProfile
  role = local.roleEc2Name
}

resource "aws_iam_role" "ec2_role" {
  depends_on = [null_resource.check_role_exists]
  count = local.roleExist == false ? 1 : 0

  name = local.roleEc2Name
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
  depends_on = [null_resource.check_role_exists]
  count = local.roleExist == false ? 1 : 0

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
  depends_on = [null_resource.check_role_exists,aws_iam_policy.ssm_policy]
  count = local.roleExist == false ? 1 : 0

  name       = "ssm_policy_attachment"
  policy_arn = aws_iam_policy.ssm_policy[0].arn
  roles = [aws_iam_role.ec2_role[0].name]
}

