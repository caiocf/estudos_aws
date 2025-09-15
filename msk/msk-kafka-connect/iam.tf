// IAM ROLE EC2 SSM

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

resource "aws_iam_role_policy" "msk_policy" {
  name = "msk_policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ],
        "Resource": [
          //"arn:aws:kafka:*:${data.aws_caller_identity.current.account_id}:cluster/${aws_msk_cluster.cluster.cluster_name}/*"
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ],
        "Resource": [
          //"arn:aws:kafka:*:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.cluster.cluster_name}/*"
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        "Resource": [
          # "arn:aws:kafka:*:*:group/${data.aws_caller_identity.current.account_id}/*"
          "*"
        ]
      }
    ]
  })

}