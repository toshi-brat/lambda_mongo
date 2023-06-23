resource "aws_iam_role" "ec2_stop" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ec2_stop_policy" {
  name = "lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
      }, {
      Effect = "Allow"
      Action = [
        "sns:Publish"
      ]
      Resource = var.sns_arn
      }, {
      Effect = "Allow"
      Action = [
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:DescribeInstances",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ]
      Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.ec2_stop_policy.arn
  role       = aws_iam_role.ec2_stop.name
}