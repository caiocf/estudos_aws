# Security Group para ALB
resource "aws_security_group" "bia_alb" {
  name        = "${var.project_name}-alb"
  description = "Security group for BIA ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "acesso publico HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "acesso publico HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_name}-alb"
  }
}

# Security Group para EC2 (ECS Cluster)
resource "aws_security_group" "bia_ec2" {
  name        = "${var.project_name}-ec2"
  description = "Security group for BIA EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "acesso vindo de bia-alb"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.bia_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# Security Group para Database
resource "aws_security_group" "bia_db" {
  name        = "${var.project_name}-db"
  description = "Security group for BIA database"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "acesso vindo de bia-ec2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bia_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db"
  }
}
