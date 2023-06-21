resource "aws_launch_template" "foo" {
  name = var.template_name
  image_id = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = var.user_data
}


resource "aws_autoscaling_group" "mongo-asg" {
  name                      = "mongo-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.snet
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "foobar" {
  for_each = var.schedule
  scheduled_action_name  = each.value["schedule_name"]
  min_size               = each.value["min_size"]
  max_size               = each.value["max_size"]
  desired_capacity       = each.value["desired_capacity"]
  start_time             = each.value["start_time"]
  recurrence = var.recurrence
  time_zone = var.time_zone
  autoscaling_group_name = aws_autoscaling_group.mongo-asg.name
}

resource "aws_autoscaling_notification" "example_notifications" {
  group_names = [aws_autoscaling_group.mongo-asg.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.asg_sns_topic
}