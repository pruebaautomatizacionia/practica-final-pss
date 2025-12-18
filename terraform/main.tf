# File: main.tf
terraform {
  backend "s3" {
    bucket         = "infrabot-tf-state-pruebaautomatizacionia"
    key            = "terraform/state.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock-table-infrabot"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  common_tags = {
    Name        = "Transfer International Project"
    Environment = "dev"
  }
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

resource "ec2_instances" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  ami        = data.aws_ami.centos8.id
  key_name   = var.key_name
  instance_count = 3
}

resource "rds" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  db_instance_class = "db.t2.micro"
}
