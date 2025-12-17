```terraform
# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS region
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "international-transfer-vpc"
  }
}

# Define the Subnets
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "international-transfer-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "international-transfer-subnet-2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "international-transfer-subnet-3"
  }
}

# Define the Security Group
resource "aws_security_group" "sg" {
  name        = "international-transfer-sg"
  description = "Security group for VMs and database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the VMs
resource "aws_instance" "vm" {
  count         = 3
  ami           = "ami-0c55b71339999999" # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id # Use subnet1 for all VMs
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "international-transfer-vm-${count.index + 1}"
  }
}

# Define the PostgreSQL Database
resource "aws_db_instance" "db" {
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t2.micro"
  name              = "international_transfer_db"
  username          = "db_user"
  password          = "db_password"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  db_subnet_group_name = "international-transfer-db-subnet-group" # Create a DB Subnet Group
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "international-transfer-db-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
}

# Output the public IP addresses of the VMs
output "vm_public_ips" {
  value = [for vm in aws_instance.vm : vm.public_ip]
}

# Output the database endpoint
output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
```