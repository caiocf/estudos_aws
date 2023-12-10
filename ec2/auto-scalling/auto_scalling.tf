resource "aws_placement_group" "my_spread_pg" {
  name     = "my-spread-placement-group"
  strategy = "spread"
}

resource "aws_launch_template" "templete_modelo" {
  name_prefix   = "webserver-templete"
  default_version = "1.0"
  image_id      = data.aws_ami.amazonLinux_regiao1.id

  instance_type = "t2.micro"
  key_name = aws_key_pair.keyPairSSH_1.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  provider = aws.primary
  monitoring {
    enabled = true
  }

  instance_market_options {
    market_type = "spot"
  }

  network_interfaces {
    subnet_id                   = module.criar_vpcA_regiao1.subnet_private_a_id
    associate_public_ip_address = false
    security_groups             =  [aws_security_group.regra_http_ssh.id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(<<EOF
        #!/bin/bash
        yum update -y
        # Instalação do SSM Agent
        yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
        echo "<center><h1>Esta EC2 está na Zona: $EC2AZ</h1></center>" > /var/www/html/index.html
        mkdir -p /var/www/html/static/
        echo "<center><h1>Esta EC2 está na Zona: $EC2AZ</h1> Conteudo Statico</center>" > /var/www/html/static/index.html
        EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_webserver" {
  name = "webserver-as"
  launch_template {
    id = aws_launch_template.templete_modelo.id
    version = aws_launch_template.templete_modelo.latest_version
  }
  vpc_zone_identifier = [module.criar_vpcA_regiao1.subnet_private_a_id,module.criar_vpcA_regiao1.subnet_private_b_id,module.criar_vpcA_regiao1.subnet_private_c_id]
  max_size = 6
  min_size = 3
  desired_capacity = 3
  health_check_grace_period = 60
  health_check_type = "EC2"

  placement_group = aws_placement_group.my_spread_pg.id

  target_group_arns = [aws_lb_target_group.tg_webserver.arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "webserver-asg-instance"
    propagate_at_launch = true
  }

}

###### Target Tracking Scaling Policies ######
# TTS - Scaling Policy-1: Based on CPU Utilization of EC2 Instances
# Define Autoscaling Policies and Associate them to Autoscaling Group
resource "aws_autoscaling_policy" "avg_cpu_policy_greater_than_50" {
  name                   = "avg-cpu-policy-greater-than-xx"
  policy_type = "TargetTrackingScaling" # Important Note: The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling". If this value isn't provided, AWS will default to "SimpleScaling."
  autoscaling_group_name = aws_autoscaling_group.asg_webserver.name
  estimated_instance_warmup = 60 # defaults to ASG default cooldown 300 seconds if not set
  # CPU Utilization is above 50
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

}

# TTS - Scaling Policy-2: Based on ALB Target Requests avg per minute
resource "aws_autoscaling_policy" "avg_per_minute_alb_request_count_policy_greater_than_100" {
  name                   = "avg-per-minute-alb-request-count-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_webserver.name
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 60 # defaults to ASG default cooldown 300 seconds if not set
 # Number of requests > 100 completed per target in an Application Load Balancer target group.
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label =  "${aws_lb.alb.arn_suffix}/${aws_lb_target_group.tg_webserver.arn_suffix}"
    }

    target_value = 100.0  # O número desejado de solicitações por segundo por instância
  }
}

###################################################################
## Create Scheduled Actions
### Create Scheduled Action-1: Increase capacity during business hours
resource "aws_autoscaling_schedule" "increase_capacity_7am" {
  scheduled_action_name  = "increase-capacity-7am"
  min_size               = 3
  max_size               = 6
  desired_capacity       = 5
  #start_time             = "2030-03-30T11:00:00Z" # Time should be provided in UTC Timezone (11am UTC = 7AM EST)
  recurrence             = "00 09 * * *"
  autoscaling_group_name = aws_autoscaling_group.asg_webserver.name
}
### Create Scheduled Action-2: Decrease capacity during business hours
resource "aws_autoscaling_schedule" "decrease_capacity_5pm" {
  scheduled_action_name  = "decrease-capacity-5pm"
  min_size               = 3
  max_size               = 6
  desired_capacity       = 3
  #start_time             = "2030-03-30T21:00:00Z" # Time should be provided in UTC Timezone (9PM UTC = 5PM EST)
  recurrence             = "00 21 * * *"
  autoscaling_group_name =  aws_autoscaling_group.asg_webserver.name
}