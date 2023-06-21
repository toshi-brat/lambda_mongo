resource "aws_iam_role" "ec2_stop" {
  name = "ec2_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_stop.name
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSM_ROLE"
  role = aws_iam_role.ec2_stop.name
}

resource "aws_instance" "mongo-server" {
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id            = var.subnet
  ami                  = var.ami
  instance_type        = "t2.micro"
  security_groups      = [var.sg]
  key_name             = var.key_pair
  user_data            = var.user_data
  tags = {
    Name    = "mongo-server"
    Made_By = "Terraform"
  }
}
