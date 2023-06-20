provider "aws" {
  region = "ap-south-1"
}
module "scheduler" {
  source = "../module/Scheduler"
  schedule = {
    schedule-1 ={
    scheduler_name = "Morning_Start"
    schedule_expression = "cron(0 9 * * ? *)"
    lambda_arn = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
    },
    schedule-2 ={
    scheduler_name = "Morning_Stop"
    schedule_expression = "cron(30 10 * * ? *)"
    lambda_arn = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
    },
    schedule-3 ={
    scheduler_name = "Evening_start"
    schedule_expression = "cron(0 17 * * ? *)"
    lambda_arn = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
    },
    schedule-4 ={
    scheduler_name = "Evening_Stop"
    schedule_expression = "cron(30 18 * * ? *)"
    lambda_arn = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
    }
  }
  scheduler_policy = {
    policy-1 = {
      policy_name = "ec2_stop_lambda_policy"
      Resource = lookup(module.lambda.lambda_arn, "ec2_stop_lambda", null).arn
  },
  policy-2 ={
      policy_name = "ec2_start_lambda_policy"
      Resource = lookup(module.lambda.lambda_arn, "ec2_start_lambda", null).arn
  }
}
}

data "archive_file" "ec2_start_lambda" {
  type        = "zip"
  source_file = "./vm_start.py"
  output_path = "vm_start.zip"
}

data "archive_file" "ec2_stop_lambda" {
  type        = "zip"
  source_file = "./vm_stop.py"
  output_path = "vm_stop.zip"
}

data "aws_iam_role" "lambda" {
  name = "LAMBDA_ROLE"
}

module "lambda" {
  source = "../module/lambda"
  lambda_role = data.aws_iam_role.lambda.arn
  lambda_runtime = "python3.9"
    lambda = {
    ec2_stop_lambda ={
    filename = "vm_stop.zip"
    function_name = "vm_stop_lambda"
    handler = "vm_stop.lambda_handler"
    source_code_hash = data.archive_file.ec2_stop_lambda.output_base64sha256
    timeout = 60
    },
    ec2_start_lambda ={
    filename = "vm_start.zip"
    function_name = "vm_start_lambda"
    handler = "vm_start.lambda_handler"
    source_code_hash = data.archive_file.ec2_start_lambda.output_base64sha256
    timeout = 60
    }
    }
}