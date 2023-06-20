variable "lambda" {
  type = map(object({
    filename = string
    function_name = string
    handler = string
    source_code_hash = string
    timeout = number
  }))
}
variable "lambda_role" {}
variable "lambda_runtime" {}