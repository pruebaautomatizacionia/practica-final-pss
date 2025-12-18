terraform {
  backend "s3" {
    bucket = "infrabot-tf-state-pruebaautomatizacionia"
    key    = "terraform/state.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-lock-table-infrabot"
  }
}

data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" { filter { name="vpc-id"; values=[data.aws_vpc.default.id] } }
data "aws_ami" "linux" { most_recent = true; owners = ["amazon"]; filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] } }

variable "key_name" { type = string }

resource "aws_instance" "web" {
  count = 3
  ami           = data.aws_ami.linux.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  key_name      = var.key_name
}

output "vm_public_ips" { value = aws_instance.web[*].public_ip }