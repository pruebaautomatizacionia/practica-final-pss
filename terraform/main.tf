  backend "s3" {
    bucket = "infrabot-tf-state-pruebaautomatizacionia"
    key = "terraform/state.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-lock-table-infrabot"
  }

  data "aws_vpc" "default" {
    default = true
  }

  data "aws_subnets" "default" {
    vpc_id = data.aws_vpc.default.id
    filter {
      name   = "tag:Name"
      values = ["subnet-privado"]
    }
  }

  data "aws_ami" "linux" {
    most_recent = true

    filter {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }

    owners = ["amazon"]
  }

  variable "key_name" {
    type = string
  }

  resource "aws_security_group" "ansible_access" {
    name        = "ansible_access"
    description = "Security group for Ansible access"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_instance" "web" {
    count = 3

    instance_type = "t3.micro"
    ami             = data.aws_ami.linux.id
    subnet_id     = data.aws_subnets.default.ids[0]
    vpc_security_group_ids = [aws_security_group.ansible_access.id]
    key_name        = var.key_name
  }

  output "vm_public_ips" {
    value = aws_instance.web[*].public_ip
  