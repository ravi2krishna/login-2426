# VPC
resource "aws_vpc" "login-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "login-vpc"
  }
}

# Subnet For Frontend
resource "aws_subnet" "login-fe-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-frontend-subnet"
  }
}

# Subnet For API/Backend
resource "aws_subnet" "login-be-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-backend-subnet"
  }
}

# Subnet For Database
resource "aws_subnet" "login-db-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "login-database-subnet"
  }
}

# Internet Gateway For WWW Access
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-internet-gateway"
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
    Name = "login-public-RT"
  }
}

# Route Table for Private
resource "aws_route_table" "login_pvt_rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-private-RT"
  }
}

# Route Table Association For Public
resource "aws_route_table_association" "login_web_asc" {
  subnet_id      = aws_subnet.login-fe-sn.id
  route_table_id = aws_route_table.login_pub_rt.id
}

resource "aws_route_table_association" "login_app_asc" {
  subnet_id      = aws_subnet.login-be-sn.id
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
    Name = "login-custom-nacl"
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

# Frontend SSH
resource "aws_vpc_security_group_ingress_rule" "login_web_sg_ssh" {
  security_group_id = aws_security_group.login_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# Frontend HTTP
resource "aws_vpc_security_group_ingress_rule" "login_web_sg_http" {
  security_group_id = aws_security_group.login_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# Frontend ALL - OutBound
resource "aws_vpc_security_group_egress_rule" "login_web_sg_outbound" {
  security_group_id = aws_security_group.login_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}
