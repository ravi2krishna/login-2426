# VPC
resource "aws_vpc" "login-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}

# Subnet For Frontend & Backend
resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.login-vpc.id
  for_each   = var.public_subnet_cidrs
  cidr_block = each.value
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Subnet For Database
resource "aws_subnet" "login-db-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.vpc_name}-database-subnet"
  }
}

# Internet Gateway For WWW Access
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Route Table for Public
resource "aws_route_table" "login_pub_rt" {
  vpc_id = aws_vpc.login-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-RT"
  }
}

# Route Table for Private
resource "aws_route_table" "login_pvt_rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-private-RT"
  }
}

# Route Table Association For Public Subnets
resource "aws_route_table_association" "login_pub_asc" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.login_pub_rt.id
}

# Route Table Association For Private
resource "aws_route_table_association" "login_db_asc" {
  subnet_id      = aws_subnet.login-db-sn.id
  route_table_id = aws_route_table.login_pvt_rt.id
}

# NACL for Custom Rules
resource "aws_network_acl" "login_custom_nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "${var.vpc_name}-custom-nacl"
  }
}

# Secuirty Group For Frontend
resource "aws_security_group" "login_web_sg" {
  name        = "frontend_sg"
  description = "Allow Frontend Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "frontend_sg"
  }
}

# Frontend Dynamic Rules
resource "aws_vpc_security_group_ingress_rule" "login_web_ingress" {
  count = length(var.web_ingress_ports)
  security_group_id = aws_security_group.login_web_sg.id
  cidr_ipv4   = var.web_ingress_ports[count.index].cidr
  from_port   = var.web_ingress_ports[count.index].port
  ip_protocol = "tcp"
  to_port     = var.web_ingress_ports[count.index].port
}

# Secuirty Group For Backend
resource "aws_security_group" "login_app_sg" {
  name        = "backend_sg"
  description = "Allow Backend Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "backend_sg"
  }
}

# Backend Dynamic Rules
resource "aws_vpc_security_group_ingress_rule" "login_app_sg_ssh" {
  count = length(var.app_ingress_ports)
  security_group_id = aws_security_group.login_app_sg.id
  cidr_ipv4   = var.app_ingress_ports[count.index].cidr
  from_port   = var.app_ingress_ports[count.index].port
  ip_protocol = "tcp"
  to_port     = var.app_ingress_ports[count.index].port
}

# Secuirty Group For Database
resource "aws_security_group" "login_db_sg" {
  name        = "database_sg"
  description = "Allow Database Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "database_sg"
  }
}

# Database Dynamic Rules
resource "aws_vpc_security_group_ingress_rule" "login_db_sg_ssh" {
  count = length(var.db_ingress_ports)
  security_group_id = aws_security_group.login_db_sg.id
  cidr_ipv4   = var.db_ingress_ports[count.index].cidr
  from_port   = var.db_ingress_ports[count.index].port
  ip_protocol = "tcp"
  to_port     = var.db_ingress_ports[count.index].port
}

locals {
  security_groups = {
    "web" = aws_security_group.login_web_sg.id
    "app" = aws_security_group.login_app_sg.id
    "db"  = aws_security_group.login_db_sg.id
  }
}

# Common ALL - OutBound
resource "aws_vpc_security_group_egress_rule" "common_egress" {
  for_each    = local.security_groups  
  security_group_id = each.value
  cidr_ipv4   = var.common_egress_rule.cidr_ipv4
  from_port   = var.common_egress_rule.from_port
  ip_protocol = var.common_egress_rule.ip_protocol
  to_port     = var.common_egress_rule.to_port
}