variable "ami" {
  description = "AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security Group For Instance"
  type        = list(string)
}

variable "user_data" {
  description = "User Data For Instance"
  type        = string
}

variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}
