resource "aws_launch_configuration" "test_vpcASG" {
  name_prefix = "terraform-lc-example"
  image_id    = "${var.image_id}"
  #image_id         = "ami-02ac29dee490a5760"
  key_name        = "${aws_key_pair.mytest-key.key_name}"
  instance_type   = "t2.micro"
  security_groups = ["${var.security_group}"]
  #  user_data = <<-EOF
  #                 #!/bin/bash 
  #                 yum install httpd -y
  #                 service httpd start
  #                 echo "Hello world" >/var/www/html/index.html
  #                 chkconfig httpd on
  #                 EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "mytest-key" {
  key_name   = "asg_key"
  public_key = "${file(var.asg_key)}"
}

resource "aws_autoscaling_group" "asgvpc_main" {
  name                      = "terraform-asg-example"
  
  launch_configuration      = "${aws_launch_configuration.test_vpcASG.name}"
  vpc_zone_identifier       = ["${var.public1_subnet}", "${var.public2_subnet}"]
  target_group_arns         = ["${var.target_group_arn}"]
  health_check_type         = "ELB"
  health_check_grace_period = 120
  force_delete              = true
  min_size                  = 1
  max_size                  = 3
  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale-out-policy" {
  name                   = "scale-up-terraform"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asgvpc_main.name}"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "high_test_alarm_" {
  alarm_name          = "High-test_alarm-vpcasg"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 High cpu utilization"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.scale-out-policy.arn}"]

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asgvpc_main.name}"
  }
}

resource "aws_autoscaling_policy" "scale-in-policy" {
  name                   = "scale-in-terraform"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asgvpc_main.name}"
  policy_type            = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "Low_test_alarm" {
  alarm_name          = "Low-test_alarm-vpcasg"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.scale-in-policy.arn}"]

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asgvpc_main.name}"
  }
}

resource "aws_autoscaling_notification" "example_notifications" {
  group_names = [
    "${aws_autoscaling_group.asgvpc_main.name}",

  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.example.arn}"
}

resource "aws_sns_topic" "example" {
  name         = "example-topic"
  display_name = "example ASG_SNS topic"

  # arn is an exported attribute
}
