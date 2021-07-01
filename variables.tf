variable "region" {
  type = string
  default = "us-east-1"
}

variable "cidr_block" {
  description = "IP range for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list
  default = ["10.0.4.0/24"]
}