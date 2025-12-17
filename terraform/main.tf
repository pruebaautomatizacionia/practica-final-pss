 Este es mi código de Terraform para crear una infraestructura con 3 máquinas virtuales en AWS y una instancia de RDS para la base de datos SQL.

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

data "aws_key_pair_id" "my_key_pair" {
  key_name = "MyKeyPair"
}

resource "aws_vpc" "transfer_international" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TransferInternationalVPC"
  }
}

data "aws_subnet_ids" "available" {
  vpc_id = aws_vpc.transfer_international.id

  tags = {
    Tier = "Public"
  }
}

locals {
  transfer_instance_type = "t2.micro"
  db_instance_class      = "db.t2.micro"
}

resource "aws_subnet" "transfer_subnet" {
  count             = 3
  cidr_block        = cidrsubnet(aws_vpc.transfer_international.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.transfer_international.id
  availability_zone = data.aws_caller_identity.current.region == "us-west-2" ? "${data.aws_region.current.name}a" : "${data.aws_region.current.name}b"

  tags = {
    Name = "TransferInternationalSubnet${count.index + 1}"
  }
}

resource "aws_internet_gateway" "transfer_internet_gateway" {
  vpc_id = aws_vpc.transfer_international.id

  tags = {
    Name = "TransferInternationalGateway"
  }
}

resource "aws_route_table" "transfer_route_table" {
  vpc_id = aws_vpc.transfer_international.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transfer_internet_gateway.id
  }

  tags = {
    Name = "TransferInternationalRouteTable"
  }
}

resource "aws_route_table_association" "transfer_route_table_association" {
  count          = length(aws_subnet.transfer_subnet)*3
  subnet_id      = aws_subnet.transfer_subnet[count.index].id
  route_table_id = aws_route_table.transfer_route_table.id
}

resource "aws_security_group" "transfer_security_group" {
  name        = "TransferInternationalSecurityGroup"
  description = "Security group for Transfer International Project"
  vpc_id      = aws_vpc.transfer_international.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "transfer_instances" {
  count = 3

  ami           = data.aws_ami.centos8.id
  instance_type = local.transfer_instance_type
  key_name      = data.aws_key_pair_id.my_key_pair.id
  subnet_id     = element(data.aws_subnet_ids.available.ids, count.index)
  vpc_security_group_ids = [aws_security_group.transfer_security_group.id]

  tags = {
    Name = "TransferInternationalInstance${count.index + 1}"
  }
}

resource "aws_db_instance" "transfer_rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = local.db_instance_class
  username               = "transfer"
  password               = "Transfer123!"
  db_name                = "transfer_international"
  multi_az               = false
  vpc_security_group_ids  = [aws_security_group.transfer_security_group.id]
  skip_final_snapshot     = true
}
```