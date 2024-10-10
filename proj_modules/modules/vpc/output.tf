output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_sg_id" {
  value = aws_security_group.pub_sg.id
}
