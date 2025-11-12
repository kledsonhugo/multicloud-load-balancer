variable "vpc_id" {}
variable "subnet1a_id" {}
variable "subnet1c_id" {}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "elb_name" {
  type    = string
  default = "elbname"
}