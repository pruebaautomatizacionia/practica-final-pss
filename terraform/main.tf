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

### EC2 INSTANCES ###
resource "aws_instance" "ec2" {
  count         = 3
  ami           = data.aws_ami.centos8.id
  instance_type = "t3.micro"
  subnet_id     = element(var.subnet_ids, count.index)
  key_name      = var.key_name

  tags = merge(
    local.common_tags,
    {
      Name = "ec2-instance-${count.index + 1}"
    }
  )
}

### RDS ###
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = local.common_tags
}

resource "aws_db_instance" "rds" {
  identifier              = "rds-dev"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "password123"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.rds.name

  tags = local.common_tags
}
