 ```hcl
# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Create a VPC with public and private subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create public subnet
resource "aws_subnet" "public" {
  count = 3
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Create route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate public subnet with route table
resource "aws_route_table_association" "public" {
  count = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create security group for VMs and database
resource "aws_security_group" "sg" {
  name        = "international-transfer-sg"
  description = "Security group for VMs and database"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Replace with the range of your private subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create PostgreSQL DB instance and associated security group
resource "aws_db_instance" "database" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  name              = "international_transfer_db"
  username          = "db_user"
  password           = var.db_password
  vpc_security_group_ids = [aws_security_group.sg.id]
}
```