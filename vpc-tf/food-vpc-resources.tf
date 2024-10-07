# VPC
resource "aws_vpc" "food-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "food-vpc"
  }
}

# Subnet For Frontend
resource "aws_subnet" "food-fe-sn" {
  vpc_id     = aws_vpc.food-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "food-frontend-subnet"
  }
}

# Subnet For API/Backend
resource "aws_subnet" "food-be-sn" {
  vpc_id     = aws_vpc.food-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "food-backend-subnet"
  }
}

# Subnet For Database
resource "aws_subnet" "food-db-sn" {
  vpc_id     = aws_vpc.food-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "food-database-subnet"
  }
}

# Internet Gateway For WWW Access
resource "aws_internet_gateway" "food-igw" {
  vpc_id = aws_vpc.food-vpc.id

  tags = {
    Name = "food-internet-gateway"
  }
}

# Route Table for Public
resource "aws_route_table" "food_pub_rt" {
  vpc_id = aws_vpc.food-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.food-igw.id
  }

  tags = {
    Name = "food-public-RT"
  }
}

# Route Table for Private
resource "aws_route_table" "food_pvt_rt" {
  vpc_id = aws_vpc.food-vpc.id

  tags = {
    Name = "food-private-RT"
  }
}

# Route Table Association For Public
resource "aws_route_table_association" "food_web_asc" {
  subnet_id      = aws_subnet.food-fe-sn.id
  route_table_id = aws_route_table.food_pub_rt.id
}

resource "aws_route_table_association" "food_app_asc" {
  subnet_id      = aws_subnet.food-be-sn.id
  route_table_id = aws_route_table.food_pub_rt.id
}

# Route Table Association For Private
resource "aws_route_table_association" "food_db_asc" {
  subnet_id      = aws_subnet.food-db-sn.id
  route_table_id = aws_route_table.food_pvt_rt.id
}

# NACL for Custom Rules
resource "aws_network_acl" "food_custom_nacl" {
  vpc_id = aws_vpc.food-vpc.id

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
    Name = "food-custom-nacl"
  }
}

# Secuirty Group For Frontend
resource "aws_security_group" "food_web_sg" {
  name        = "frontend_sg"
  description = "Allow Frontend Traffic"
  vpc_id      = aws_vpc.food-vpc.id

  tags = {
    Name = "frontend_sg"
  }
}

# Frontend SSH
resource "aws_vpc_security_group_ingress_rule" "food_web_sg_ssh" {
  security_group_id = aws_security_group.food_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# Frontend HTTP
resource "aws_vpc_security_group_ingress_rule" "food_web_sg_http" {
  security_group_id = aws_security_group.food_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# Frontend ALL - OutBound
resource "aws_vpc_security_group_egress_rule" "food_web_sg_outbound" {
  security_group_id = aws_security_group.food_web_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}

# Secuirty Group For Backend
resource "aws_security_group" "food_app_sg" {
  name        = "backend_sg"
  description = "Allow Backend Traffic"
  vpc_id      = aws_vpc.food-vpc.id

  tags = {
    Name = "backend_sg"
  }
}

# Backend SSH
resource "aws_vpc_security_group_ingress_rule" "food_app_sg_ssh" {
  security_group_id = aws_security_group.food_app_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# Backend HTTP
resource "aws_vpc_security_group_ingress_rule" "food_app_sg_http" {
  security_group_id = aws_security_group.food_app_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}

# Backend ALL - OutBound
resource "aws_vpc_security_group_egress_rule" "food_app_sg_outbound" {
  security_group_id = aws_security_group.food_app_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}

# Secuirty Group For Database
resource "aws_security_group" "food_db_sg" {
  name        = "database_sg"
  description = "Allow Database Traffic"
  vpc_id      = aws_vpc.food-vpc.id

  tags = {
    Name = "database_sg"
  }
}

# Database SSH
resource "aws_vpc_security_group_ingress_rule" "food_db_sg_ssh" {
  security_group_id = aws_security_group.food_db_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# Database POSTGRES
resource "aws_vpc_security_group_ingress_rule" "food_db_sg_mysql" {
  security_group_id = aws_security_group.food_db_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

# Database ALL - OutBound
resource "aws_vpc_security_group_egress_rule" "food_db_sg_outbound" {
  security_group_id = aws_security_group.food_db_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}