resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
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
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_security_group" "web_ssh" {
  name        = "${var.project}-web-ssh-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
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
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

resource "aws_instance" "vm_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_ssh.id]
  key_name               = var.key_name

  tags = {
    Name        = "${var.project}-vm-1"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_instance" "vm_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.web_ssh.id]
  key_name               = var.key_name

  tags = {
    Name        = "${var.project}-vm-2"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_instance" "vm_3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_ssh.id]
  key_name               = var.key_name

  tags = {
    Name        = "${var.project}-vm-3"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}