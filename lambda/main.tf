provider "aws" {
  region = "ap-south-1"
}
module "scheduler" {
  source = "../module/Scheduler"
  schedule = {
    schedule-1 = {
      scheduler_name      = "Morning_Start"
      schedule_expression = "cron(15 5 * * ? *)"
      lambda_arn          = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
    },
    schedule-2 = {
      scheduler_name      = "Morning_Stop"
      schedule_expression = "cron(30 5 * * ? *)"
      lambda_arn          = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
    },
    schedule-3 = {
      scheduler_name      = "Evening_start"
      schedule_expression = "cron(45 5 * * ? *)"
      lambda_arn          = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
    },
    schedule-4 = {
      scheduler_name      = "Evening_Stop"
      schedule_expression = "cron(0 6 * * ? *)"
      lambda_arn          = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
    }
  }
  scheduler_policy = {
    policy-1 = {
      policy_name = "ec2_stop_lambda_policy"
      Resource    = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
    },
    policy-2 = {
      policy_name = "ec2_start_lambda_policy"
      Resource    = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
    }
  }
}

data "archive_file" "ec2_start_lambda" {
  type        = "zip"
  source_dir = "./start_lambda"
  output_path = "./start_lambda/vm_start.zip"
}

data "archive_file" "ec2_stop_lambda" {
  type        = "zip"
  source_dir = "./stop_lambda"
  output_path = "./stop_lambda/vm_stop.zip"
}

data "aws_iam_role" "lambda" {
  name = "LAMBDA_ROLE"
}

data "aws_sns_topic" "sns" {
  name = "mongo-alert"
}

data "aws_instance" "ec2" {
  filter {
    name   = "tag:Name"
    values = ["mongo-server"]
  }
  filter {
    name   = "tag:Made_By"
    values = ["terraform"]
  }
}

module "lambda" {
  source         = "../module/lambda"
  lambda_role    = data.aws_iam_role.lambda.arn
  lambda_runtime = "python3.9"
  lambda = {
    ec2_stop_lambda = {
      filename         = "vm_stop.zip"
      function_name    = "vm_stop_lambda"
      handler          = "vm_stop.lambda_handler"
      source_code_hash = data.archive_file.ec2_stop_lambda.output_base64sha256
      timeout          = 60
    },
    ec2_start_lambda = {
      filename         = "vm_start.zip"
      function_name    = "vm_start_lambda"
      handler          = "vm_start.lambda_handler"
      source_code_hash = data.archive_file.ec2_start_lambda.output_base64sha256
      timeout          = 60
    }
  }
  lambda_env = {
    sns_arn_running = data.aws_sns_topic.sns.arn
    instance_id     = data.aws_instance.ec2.id
  }
}