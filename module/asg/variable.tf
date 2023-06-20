variable "sg" {}
variable "snet"{}

variable "schedule" {
  type = map(object({
    schedule_name = string
    min_size = string
    max_size= string
    desired_capacity=string
    start_time=string
  }))
}
variable "template_name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "asg_sns_topic" {}
variable "user_data" {}
