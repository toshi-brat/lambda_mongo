resource "aws_lambda_function" "mongo_lambda" {
  for_each = var.lambda
  filename      = each.value["filename"]
  function_name = each.value["function_name"]
  role          = var.lambda_role
  handler       = each.value["handler"]
  source_code_hash = each.value["source_code_hash"]
  runtime = var.lambda_runtime
  timeout = each.value["timeout"]
  environment {
    variables = var.lambda_env
  }
}
