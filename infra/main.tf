provider "aws" {
  region = "ap-south-1"
}
data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source   = "../module/network"
  cidr     = "10.0.0.0/20"
  app_name = "test"
  pub-snet-details = {
    s1 = {
      cidr_block        = "10.0.0.0/22"
      availability_zone = "ap-south-1a"
    },
    s2 = {
    cidr_block        = "10.0.4.0/22"
    availability_zone = "ap-south-1b"
    }
  }
  pri-snet-details = {
    ps1 = {
      cidr_block        = "10.0.8.0/22"
      availability_zone = "ap-south-1a"
    }
  }
}

module "sg" {
  source = "../module/sg"
  sg_details = {
    "mongo-server" = {
      description = "inbound"
      name        = "mongo-server"
      vpc_id      = module.network.vpc-id
      ingress_rules = [
        {
          cidr_blocks     = ["0.0.0.0/0"]
          from_port       = 3000
          protocol        = "tcp"
          self            = null
          to_port         = 3000
          security_groups = null
        },
        {
          cidr_blocks     = ["0.0.0.0/0"]
          from_port       = 8080
          protocol        = "tcp"
          self            = null
          to_port         = 8080
          security_groups = null
        },
        {
          cidr_blocks     = ["0.0.0.0/0"]
          from_port       = 27017
          protocol        = "tcp"
          self            = null
          to_port         = 27017
          security_groups = null
        }
      ]
    }
  }
}

module "ec2" {
  source = "../module/ec2"
  subnet = lookup(module.network.pub-snet-id, "s1", null).id
  ami = "ami-0f5ee92e2d63afc18"
  sg = lookup(module.sg.output-sg-id, "mongo-server", null)
  user_data = file("${path.module}/user_data.sh")
  key_pair="aws_key_test"
}  

module "asg" {
  source          = "../module/asg"
  user_data = filebase64("${path.module}/user_data.sh")
  ami             = "ami-0f5ee92e2d63afc18"
  instance_type   = "t2.micro"
  recurrence = "* * * * 1-5"
  time_zone = "Asia/Kolkata"
  snet        = [lookup(module.network.pub-snet-id, "s1", null).id , lookup(module.network.pub-snet-id, "s2", null).id]
  sg              = lookup(module.sg.output-sg-id, "mongo-server", null)  
  asg_sns_topic = module.sns.sns-arn
  template_name = "mongo_template"
  key_name ="aws_key_test"
  schedule = {
  morning-up = {
    schedule_name = "Moring-0930"
    min_size = "3"
    max_size = "3"
    desired_capacity = "3"
    start_time = "2023-06-21T05:30:00Z" //time should be in UTC
  },
    morning-down = {
    schedule_name = "Morning-1030"
    min_size = "1"
    max_size = "1"
    desired_capacity = "1"
    start_time = "2023-06-21T05:40:00Z"
  },
    evening-up = {
    schedule_name = "Evening-1700"
    min_size = "3"
    max_size = "3"
    desired_capacity = "3"
    start_time = "2023-06-21T05:50:00Z"
  },
    evening-down = {
    schedule_name = "Evening-1830"
    min_size = "1"
    max_size = "1"
    desired_capacity = "1"
    start_time = "2023-06-21T06:00:00Z"
  }
 }
}

module "sns" {
  source = "../module/SNS"
  sns_name = "mongo-alert"
  email = "krishn.tushar@gmail.com"
}

module "lambda-iam"{
  source = "../module/IAM"
  lambda_role_name = "LAMBDA_ROLE"
  sns_arn = module.sns.sns-arn
}

