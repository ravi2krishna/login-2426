# Variable Access Key
variable "aws_access_key" {}

# Variable Secret Key
variable "aws_secret_key" {}

# Variable VPC CIDR
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

# Variable VPC Tenancy
variable "vpc_tenancy" {
    type = string
    default = "default"
}

# Variable VPC Name
variable "vpc_name" {
    type = string
    default = "login"
}

# Variable for Public Subntes & CIDRS
variable "public_subnet_cidrs" {
    type = map(string)
    default = {
        "frontend" = "10.0.0.0/24",
        "backend" = "10.0.1.0/24"
    }
}

# Variable for Private Subntes 
variable "private_subnet_cidr" {
    type = "string"
    default = "10.0.2.0/24"
}

# Variable for Web SG Ingress Ports
variable "web_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0" },  # SSH
    { port = 80, cidr = "0.0.0.0/0" }   # HTTP
  ]
}

# Variable for App SG Ingress Ports
variable "app_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0" },   # SSH
    { port = 8080, cidr = "0.0.0.0/0" }  # App-specific
  ]
}

# Variable for DB SG Ingress Ports
variable "db_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "10.0.0.0/16" },   # SSH (restricted)
    { port = 5432, cidr = "10.0.0.0/16" }  # Postgres (restricted)
  ]
}

# Variable for Egress All 
variable "common_egress_rule" {
  default = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 0
    ip_protocol = "tcp"
    to_port     = 65535
  }
}
