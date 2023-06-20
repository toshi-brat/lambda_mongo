resource "aws_iam_role" "scheduler_role" {
  name = "scheduler-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "scheduler.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "scheduler_policy" {
  for_each = var.scheduler_policy
  name        = each.value["policy_name"]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
      "lambda:InvokeFunction"
      ]
      Resource = each.value["Resource"]
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  for_each = aws_iam_policy.scheduler_policy
  policy_arn = each.value.arn
  role = aws_iam_role.scheduler_role.name
}


resource "aws_scheduler_schedule" "example" {
  for_each = var.schedule
  name       = each.value["scheduler_name"]
  group_name = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = each.value["schedule_expression"]
  target {
    arn      = each.value["lambda_arn"]
    role_arn = aws_iam_role.scheduler_role.arn
  }
}