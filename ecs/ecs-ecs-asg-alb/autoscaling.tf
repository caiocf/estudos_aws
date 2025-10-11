# ECS Service Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 6
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.bia.name}/${aws_ecs_service.bia.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ECS Service Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "RequestPorMinutoPorTarget"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 150.0

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.bia.arn_suffix}/${aws_lb_target_group.bia.arn_suffix}"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
