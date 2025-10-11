# ECS Cluster
resource "aws_ecs_cluster" "bia" {
  name = "cluster-${var.project_name}-alb"

  tags = {
    Name = "cluster-${var.project_name}-alb"
  }
}

# Launch Template
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-ecs-"
  image_id      = "ami-004f01eab3cd7e439" # Amazon Linux 2 ECS-optimized
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.bia_ec2.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.bia.name} >> /etc/ecs/ecs.config
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ecs-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project_name}-ecs-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.bia.arn]
  health_check_type   = "ELB"

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "bia" {
  family                   = "task-def-${var.project_name}-alb"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = "${data.aws_ecr_repository.bia.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "DB_HOST"
          value = split(":", aws_db_instance.bia.endpoint)[0]
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.bia.db_name
        },
        {
          name  = "DB_USER"
          value = aws_db_instance.bia.username
        },
        {
          name  = "DB_PASS"
          value = var.db_password
        },
        {
          name  = "DB_PORT"
          value = "5432"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-create-group"  = "true"
        }
      }

      memory = 512

      essential = true
    }
  ])

  tags = {
    Name = "task-def-${var.project_name}-alb"
  }
}

# ECS Service
resource "aws_ecs_service" "bia" {
  name            = "service-${var.project_name}-alb"
  cluster         = aws_ecs_cluster.bia.id
  task_definition = aws_ecs_task_definition.bia.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.bia.arn
    container_name   = var.project_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.bia]

  tags = {
    Name = "service-${var.project_name}-alb"
  }
}
