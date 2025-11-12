variable "vpc_id" {}
variable "subnet1a_id" {}
variable "subnet1c_id" {}
variable "vpc_cidr_block" {}

variable "elb_name" {
  type    = string
  default = "elbname"
}