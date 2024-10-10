module "login_vpc" {
    source              = "./modules/vpc"
    vpc_cidr            = "10.0.0.0/16"
    vpc_name            = "login"
    public_subnet_cidr  = "10.0.1.0/24"
    availability_zone   = "us-west-2a"
}

module "login_ec2" {
    source              = "./modules/ec2"
    ami                 = "ami-0075013580f6322a1"
    instance_type       = "t2.micro"
    subnet_id           = module.login_vpc.public_subnet_id
    key_name            = "2429"
    vpc_security_group_ids = [module.login_vpc.public_sg_id]
    user_data           = file("login_app.sh")
    instance_name       = "login-server"
}

output "login_instance_ip" {
  value = module.login_ec2.instance_ip
}