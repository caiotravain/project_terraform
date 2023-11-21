terraform {

    backend "s3" {
    bucket  = "travas-bucket"
    key     = "tf-states/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-example"
  }
}

output "my_vpc_id" {
  value = aws_vpc.my_vpc.id
}




module "rds" {
  source = "./modules/rds"
  vpc_id = aws_vpc.my_vpc.id
  rds_subnet_ids = [module.network.rds_subnet_private_1, module.network.rds_subnet_private_2, module.network.rds_subnet_public_1, module.network.rds_subnet_public_2]
  lb_id = module.load_balancer.lb_id
  security_group_id = module.network.security_group_id
}

module "Scalling" {
  source = "./modules/Scalling"
  id_arn = module.load_balancer.id_arn
  rds_subnet_ids = [module.network.rds_subnet_private_1, module.network.rds_subnet_private_2, module.network.rds_subnet_public_1, module.network.rds_subnet_public_2]
  security_group_id = module.network.security_group_id
  postgres_url = module.rds.postgres_url
  lb_id = module.load_balancer.lb_id
}


module "load_balancer" {
  source = "./modules/load_balancer"
  vpc_id = aws_vpc.my_vpc.id
  rds_subnet_ids = [module.network.rds_subnet_private_1, module.network.rds_subnet_private_2, module.network.rds_subnet_public_1, module.network.rds_subnet_public_2]
  security_group_id = module.network.security_group_id
}
module "network" {
  source = "./modules/network"
  vpc_id = aws_vpc.my_vpc.id
  rds_subnet_ids =[module.network.rds_subnet_private_1, module.network.rds_subnet_private_2, module.network.rds_subnet_public_1, module.network.rds_subnet_public_2]
  security_group_id = module.network.security_group_id
}

output "url" {
  value = module.rds.postgres_url
  sensitive = true
}


