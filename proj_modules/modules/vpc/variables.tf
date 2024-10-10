variable "vpc_cidr" {
    description = "CIDR for VPC"
    type        = string
}

variable "vpc_name" {
    description = "Name for VPC"
    type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
}

