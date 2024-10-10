# Variable Access Key
variable "aws_access_key" {}

# Variable Secret Key
variable "aws_secret_key" {}

# AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}