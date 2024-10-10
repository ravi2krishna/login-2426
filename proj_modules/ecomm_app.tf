module "ecomm_vpc" {
    source              = "./modules/vpc"
    vpc_cidr            = "192.168.0.0/16"
    vpc_name            = "ecomm"
    public_subnet_cidr  = "192.168.1.0/24"
    availability_zone   = "us-west-2b"
}

module "ecomm_ec2" {
    source              = "./modules/ec2"
    ami                 = "ami-0075013580f6322a1"
    instance_type       = "t2.micro"
    subnet_id           = module.ecomm_vpc.public_subnet_id
    key_name            = "2429"
    vpc_security_group_ids = [module.ecomm_vpc.public_sg_id]
    user_data           = file("ecomm_app.sh")
    instance_name       = "ecomm-server"
}

output "instance_ip" {
  value = module.ecomm_ec2.instance_ip
}