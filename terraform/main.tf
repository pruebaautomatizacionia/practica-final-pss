resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project}-public-subnet-1"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project}-public-subnet-2"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_security_group" "web_ssh" {
  name        = "${var.project}-web-ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-web-ssh-sg"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_ssh.id]

  tags = {
    Name        = "${var.project}-web-server-1"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_2.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_ssh.id]

  tags = {
    Name        = "${var.project}-web-server-2"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

