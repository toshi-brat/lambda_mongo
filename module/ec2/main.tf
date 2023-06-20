resource "aws_iam_role" "ec2_stop" {
  name = var.lambda_role_name
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
  role = aws_iam_role.ec2_stop.name
}

resource "aws_instance" "mongo-server" {
  subnet_id = var.subnet
  ami           = var.ami
  instance_type = "t2.micro"
  security_groups = [var.sg]
  key_name = "aws_key_test"
  user_data = var.user_data
  tags = {
    Name = "mongo-server"
  }
 }
