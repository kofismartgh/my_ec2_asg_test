
resource "aws_autoscaling_group" "ussd_api" {
  name                      = "ussd_api_asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.ussd_api.arn]
  force_delete              = false
  launch_template {
    id = aws_launch_template.ussd_api_launch_t.id
    version = "$Latest"
  }
  vpc_zone_identifier       = ["subnet-0def7a0a927cb38e5", "subnet-0b99eacc0848e8019"]

  tag {
    key                 = "ManagedBy"
    value               = "asgterraform"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ussd_api" {
  name                   = "ussd_api_asg_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ussd_api.name
}

#Cloud Watch Metric for Scaling Up
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "ussdapi_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "40"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ussd_api.name
  }
  alarm_actions = [ aws_autoscaling_policy.ussd_api.arn ]


}