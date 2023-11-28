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
   default_tags {
    tags = {
      Environment     = "Caio"
      Service         = "CAIO-SERVICE"
      CostCenter  = "CAIO-COSTCENTER"
      # project = aws_ce_cost_allocation_tag.example.tag_value
    }
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "caio-vpc"
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



variable "node_size" {
    description = "Size of total nodes"
    default = 2
}

variable "locust_plan_filename" {
    default = "locust/basic.py"
}

module "loadtest-distribuited" {

    source  = "marcosborges/loadtest-distribuited/aws"

    name = "nome-da-implantacao-locust"
    nodes_size = var.node_size
    executor = "locust"
    loadtest_dir_source = "./plan/"

    # LEADER ENTRYPOINT
    loadtest_entrypoint = <<-EOT
        python3 -m pip install urllib3==1.26.15
         nohup locust  -f ../loadtest/locust/basic.py --expect-workers=2  --master > ../loadtest/locust-leader.out 2>&1 &
    EOT

    # NODES ENTRYPOINT
    node_custom_entrypoint = <<-EOT
        python3 -m pip install urllib3==1.26.15
        nohup locust -f ../loadtest/locust/basic.py  --worker --master-host={LEADER_IP} > ../loadtest/locust-worker.out 2>&1 &
    EOT


    subnet_id = module.network.rds_subnet_public_2
    locust_plan_filename = var.locust_plan_filename
}


output "dashboard_url" {
    value = "http://${coalesce(module.loadtest-distribuited.leader_public_ip, module.loadtest-distribuited.leader_private_ip)}"
    description = "The URL of the Locust UI."
}


#   aws_security_group.rds_sg.id = aws_security_group.loadtest.id



data "aws_security_group" "loadtest_sg" {
  name = "nome-da-implantacao-locust-loadtest-seg"  # Replace with the actual name of your security group
  depends_on = [module.loadtest-distribuited]
}
resource "aws_security_group_rule" "loadtest_sg_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.loadtest_sg.id
}




