 ```hcl
# File: main.tf

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "centos8" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 8*x64 HVM ENA Support*GP2*NA*amzn2-ami-hvm-2.0.xxxx-xx-amd64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

variable "vpc_id" {}
variable "subnet_ids" {}
variable "key_name" {}

module "ec2_instances" {
  source = "./ec2_instance"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  ami        = data.aws_ami.centos8.id
  key_name   = var.key_name
}

module "rds" {
  source = "./rds"
}
```