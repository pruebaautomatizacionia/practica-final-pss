 Based on your request, here's a Terraform script that creates a multi-instance setup with an RDS instance for the specified project:

```hcl
terraform {
  required_version = ">= 1.4.0"
  backend "s3" {}
}

variable "aws_region" {}
provider "aws" {
  region = var.aws_region
}

variable "environment" {}
variable "project" {}
variable "owner" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_subnet" "main" {
  count = 3
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_security_group" "allow_all" {
  name        = "${var.project}-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "transferencia-internacional" {
  count = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main[count.index].id
  key_name      = "your-key-pair"

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class          = "db.t2.micro"
  username               = "your-username"
  password               = "your-password"
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
  publicly_accessible     = true

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [for subnet in aws_subnet.main : subnet.id]
}
```